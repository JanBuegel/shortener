# app/models/link.rb
class Link < ApplicationRecord
  validates :original_url, presence: true
  validates :short_token, uniqueness: true

  before_create :generate_short_token

  private

  def generate_short_token
    self.short_token = loop do
      token = SecureRandom.urlsafe_base64(4)
      break token unless Link.exists?(short_token: token)
    end
  end
end