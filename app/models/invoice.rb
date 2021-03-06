# == Schema Information
#
# Table name: invoices
#
#  id                :integer          not null, primary key
#  stripe_invoice_id :string
#  brand_id          :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  paid_at           :datetime
#  amount            :integer
#  data              :jsonb            not null
#  period_start      :datetime
#  period_end        :datetime
#  payment_failed    :boolean          default(FALSE)
#

class Invoice < ApplicationRecord
  belongs_to :brand
  has_many   :invoice_adjustments

  SUBSCRIPTION_LINE_ITEM_TYPE = 'subscription'
  INVOICE_ITEM_LINE_ITEM_TYPE = 'invoiceitem'

  # @return [FriendlyHash]
  def data
    @data ||= FriendlyHash.new(read_attribute(:data))
  end

  # @return [Hash]
  def normalize_data
    {
      period_start: data.period_start,
      period_end:   data.period_end,
      amount_due:   data.amount_due,
      paid:         data.paid,
      total:        data.total,
      line_items:   normalize_line_items
    }
  end

  # @return [Array<Hash>]
  def normalize_line_items
    line_items.map do |line_item|
      {
        amount: line_item.amount,
        period: line_item.period,
        plan_name: line_item.plan.name
      }
    end
  end

  # @return [Array<FriendlyHash>]
  def line_items
    data.lines.data
  end

  # @return [FriendlyHash]
  def subscription_line_item
    @subscription_line_item ||= line_items.find do |line_item|
      subscription_line_item?(line_item) ||
      prorated_subscription_line_item?(line_item)
    end
  end

  # @return [Fixnum]
  def subscription_line_item_amount
    subscription_line_item.try(:amount) || 0
  end

  # @return [Fixnum]
  def invoice_adjustment_amount
    invoice_adjustments.sum(:amount) || 0
  end

  # This sums the original subscription amount for the billing period
  # plus any adjustments made from upgrading the plan. The plan adjustments
  # will show up and be charged on the next stripe invoice but we tie them
  # in our db to the previous invoice so that we can keep track of what the
  # maximum amount was paid for by the customer for that billing period.
  # Stripe will take care of proration for downgrades. All we care about is
  # that when a user upgrades to a plan, they should pay that amount in full.
  # @return [Fixnum]
  def total_adjusted_amount
    subscription_line_item_amount + invoice_adjustment_amount
  end

  # @return [Float]
  def proration_ratio
    @proration_ratio ||= 1 - (
      subscription_line_item.plan.amount - subscription_line_item.amount
    ) / subscription_line_item.plan.amount.to_f
  end

  private

  def subscription_line_item?(line_item)
    line_item.type == SUBSCRIPTION_LINE_ITEM_TYPE
  end

  # A subscription line item can also be an invoice item
  # @return [Boolean]
  def prorated_subscription_line_item?(line_item)
    !!line_item.description[/^Time\son\s/] &&
    line_item.proration                    &&
    line_item.has_key?(:plan)              &&
    !line_item.subscription.nil?           &&
    line_item.type == INVOICE_ITEM_LINE_ITEM_TYPE
  end
end
