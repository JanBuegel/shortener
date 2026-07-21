# app/models/link.rb
class Link < ApplicationRecord
  ALLOWED_URL_SCHEMES = %w[http https].freeze

  validates :original_url, presence: true, length: { maximum: 2048 }
  validate :original_url_must_be_http_or_https
  validates :short_token, uniqueness: true

  before_validation :generate_short_token, on: :create

  private

  def generate_short_token
    return if short_token.present?

    self.short_token = loop do
      token = SecureRandom.urlsafe_base64(4)
      break token unless Link.exists?(short_token: token)
    end
  end

  def original_url_must_be_http_or_https
    return if original_url.blank?

    uri = URI.parse(original_url)
    unless uri.is_a?(URI::HTTP) && uri.host.present? && ALLOWED_URL_SCHEMES.include?(uri.scheme)
      errors.add(:original_url, "must be a valid http or https URL")
    end
  rescue URI::InvalidURIError
    errors.add(:original_url, "must be a valid http or https URL")
  end
end