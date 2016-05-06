# == Schema Information
#
# Table name: brands
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Brand < ActiveRecord::Base
  has_many :users
  has_many :identities
  has_many :listen_signals
  has_many :response_groups, through: :listen_signals

  has_one :twitter_identity, -> { where(provider: Identity::Provider::TWITTER) }, class_name: 'Identity'
  has_one :tweet_tracker,      class_name: 'TwitterTracker'
  has_one :twitter_dm_tracker, class_name: 'TwitterDirectMessageTracker'

  after_create :create_trackers

  class << self
    # @param brand_id [Fixnum]
    # @return         [ActiveRecord::Relation]
    def find_with_trackers(brand_id)
      includes(:tweet_tracker, :twitter_dm_tracker)
        .where(id: brand_id)
        .first
    end
  end

  def get_token_info(provider)
    encrypted_token  = identities.where(provider: provider).first.encrypted_token
    encrypted_secret = identities.where(provider: provider).first.encrypted_secret

    keys = {
      provider: provider,
      token:    Identity.decrypt(encrypted_token),
      secret:   Identity.decrypt(encrypted_secret)
    }
  end

  # Twitter provider specific methods

  # @return [Twitter::REST::Client]
  def twitter_rest_client
    @twitter_rest_client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TW_KEY']
      config.consumer_secret     = ENV['TW_SECRET']
      config.access_token        = twitter_identity.decrypted_token
      config.access_token_secret = twitter_identity.decrypted_secret
    end
  end

  # @return [Twitter::Streaming::Client]
  def twitter_streaming_client
    @twitter_streaming_client ||= Twitter::Streaming::Client.new do |config|
      config.consumer_key        = ENV['TW_KEY']
      config.consumer_secret     = ENV['TW_SECRET']
      config.access_token        = twitter_identity.decrypted_token
      config.access_token_secret = twitter_identity.decrypted_secret
    end
  end

  # @return [Fixnum|Bignum]
  def twitter_id
    twitter_identity.uid.to_i
  end

  private

  def create_trackers
    TwitterTracker.create(brand_id: id)
    TwitterDirectMessageTracker.create(brand_id: id)
  end
end