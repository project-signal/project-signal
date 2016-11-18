# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  brand_id               :integer
#  provider               :string           default("email"), not null
#  uid                    :string           default(""), not null
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  tokens                 :json
#  email_subscription     :boolean          default(FALSE)
#

require 'rails_helper'

describe User do
  let(:identity)              { create(:identity) }
  let(:brand)                 { create(:brand) }
  let(:subscription_worker)   { EmailSubscriptionWorker }
  let(:unsubscription_worker) { EmailRemoveSubscriptionWorker }

  context 'subscribing' do
    context 'previously subscribed' do
      let(:user) { create(:user, email_subscription: true) }

      it 'does not resubscribe to newsletter' do
        expect(user).not_to receive(:unsubscribe_previous_email_from_newsletter)
        expect(user).not_to receive(:subscribe_to_newsletter)

        user.update!(email_subscription: true)

        expect(user.email_subscription).to be_truthy
      end

      context 'with email update' do
        let(:new_email) { 'changed_email@test.com' }

        it 'unsubscribes previous email' do
          expect(user).to receive(:unsubscribe_previous_email_from_newsletter)

          user.update!(email: new_email, email_subscription: true)

          expect(user.email_subscription).to be_truthy
        end

        it 'subscribes new email' do
          expect(user).to receive(:subscribe_to_newsletter)

          user.update!(email: new_email, email_subscription: true)

          expect(user.email_subscription).to be_truthy
        end
      end
    end

    context 'previously unsubscribed' do
      let(:user) { create(:user, email_subscription: false) }

      it 'subscribes to newsletter' do
        expect(user).not_to receive(:unsubscribe_previous_email_from_newsletter)
        expect(user).to receive(:subscribe_to_newsletter)

        user.update!(email_subscription: true)

        expect(user.email_subscription).to be_truthy
      end

      context 'with email update' do
        let(:new_email) { 'changed_email@test.com' }

        it 'does not unsubscribes previous email again' do
          expect(user).not_to receive(:unsubscribe_previous_email_from_newsletter)

          user.update!(email: new_email, email_subscription: true)

          expect(user.email_subscription).to be_truthy
        end

        it 'subscribes new email' do
          expect(user).to receive(:subscribe_to_newsletter)

          user.update!(email: new_email, email_subscription: true)

          expect(user.email_subscription).to be_truthy
        end
      end
    end
  end

  context 'unsubscribing' do
    context 'previously subscribed' do
      let(:user) { create(:user, email_subscription: true) }

      it 'unsubsribes to newsletter' do
        expect(user).not_to receive(:subscribe_to_newsletter)
        expect(user).to receive(:unsubscribe_from_newsletter)

        user.update!(email_subscription: false)

        expect(user.email_subscription).to be_falsey
      end

      context 'with email update' do
        let(:new_email) { 'changed_email@test.com' }

        it 'unsubscribes previous email' do
          expect(user).to receive(:unsubscribe_previous_email_from_newsletter)

          user.update!(email: new_email, email_subscription: false)

          expect(user.email_subscription).to be_falsey
        end

        it 'does not subscribe with new email' do
          expect(user).not_to receive(:subscribe_to_newsletter)

          user.update!(email: new_email, email_subscription: false)

          expect(user.email_subscription).to be_falsey
        end
      end
    end

    context 'previously unsubscribed' do
      let(:user) { create(:user, email_subscription: false) }

      it 'does not unsubscribe again' do
        expect(user).not_to receive(:unsubscribe_previous_email_from_newsletter)
        expect(user).not_to receive(:subscribe_to_newsletter)

        user.update!(email_subscription: false)

        expect(user.email_subscription).to be_falsey
      end

      context 'with email update' do
        let(:new_email) { 'changed_email@test.com' }

        it 'does not unsubscribes previous email again' do
          expect(user).not_to receive(:unsubscribe_previous_email_from_newsletter)

          user.update!(email: new_email, email_subscription: false)

          expect(user.email_subscription).to be_falsey
        end
      end
    end
  end
end
