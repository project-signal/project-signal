# == Schema Information
#
# Table name: twitter_responses
#
#  id            :integer          not null, primary key
#  from          :string           not null
#  to            :string           not null
#  hashtag       :string           not null
#  date          :date             not null
#  tweet_id      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  response_id   :integer          not null
#  response_type :string           not null
#

require 'rails_helper'

describe TwitterResponse do
  describe '.mass_insert_twitter_responses' do
    let(:args) do
      [
        Date.current,
        'signal',
        'deals',
        (1..4).map { |n| { screen_name: "user#{n}", response_id: n, response_type: 'Tweet' } }
      ]
    end

    it 'can mass insert twitter responses' do
      expect {
        described_class.mass_insert_twitter_responses(*args)
      }.to change { TwitterResponse.tweets.count }.from(0).to(4)
    end
  end
end