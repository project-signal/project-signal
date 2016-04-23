# == Schema Information
#
# Table name: identities
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  brand_id         :integer
#  provider         :string
#  uid              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  encrypted_token  :string
#  encrypted_secret :string
#

class Identity < ActiveRecord::Base

  belongs_to :user
  belongs_to :brand
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  ENCRYPTION_KEY = "some password obviously make it env variable"

  def self.find_for_oauth(auth)
    find_or_create_by!(uid: auth.uid, provider: auth.provider) do |a|
      a.uid = auth.uid,
      a.provider = auth.provider,
      a.encrypted_token = encrypt(auth.extra.access_token.token),
      a.encrypted_secret = encrypt(auth.extra.access_token.secret)
    end
  end

  def self.encrypt(key)
    cipher = Gibberish::AES.new(ENCRYPTION_KEY)
    cipher.encrypt(key)
  end

  def self.decrypt(encrypted_key)
    cipher = Gibberish::AES.new(ENCRYPTION_KEY)
    cipher.decrypt(encrypted_key)
  end
end
