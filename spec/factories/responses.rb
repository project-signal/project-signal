# == Schema Information
#
# Table name: responses
#
#  id                :integer          not null, primary key
#  message           :text
#  response_type     :string
#  response_group_id :integer
#  expiration_date   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  priority          :integer
#  deleted_at        :datetime
#

FactoryGirl.define do
  factory :response do
    message 'check out this zebra!'
    response_type 'direct_message'
    response_group

    trait :default do
      message 'this is the default message'
      response_type 'default'
      priority Response::DEFAULT_PRIORITY[Response::Type::DEFAULT]
    end

    trait :expired do
      message 'this is the expired message'
      response_type 'expired'
      priority 2
    end

    trait :first do
      message 'this is the first response'
      response_type 'first'
      priority 1
    end

    trait :repeat do
      message 'this is the repeat response'
      response_type 'repeat'
      priority Response::DEFAULT_PRIORITY[Response::Type::REPEAT]
    end

    trait :timed do
      message 'this is the timed response'
      response_type 'timed'
      expiration_date 2.days.from_now
    end
  end
end
