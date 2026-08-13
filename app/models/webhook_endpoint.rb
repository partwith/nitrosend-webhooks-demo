class WebhookEndpoint < ApplicationRecord
  EVENT_TYPES = %w[hard_bounce soft_bounce complaint].freeze
  GRACE_WINDOW = 24.hours

  belongs_to :workspace
  has_many :webhook_deliveries, dependent: :destroy

  validates :url, presence: true, format: { with: %r{\Ahttps?://\S+\z}, message: "must start with http:// or https://" }
  validates :events, presence: true
  validate { errors.add(:events, "contains an unknown event type") unless (events - EVENT_TYPES).empty? }

  before_create { self.signing_secret ||= self.class.generate_secret }

  def self.generate_secret = "whsec_#{SecureRandom.alphanumeric(32)}"

  def rotate_secret!
    update!(previous_secret: signing_secret, signing_secret: self.class.generate_secret, secret_rotated_at: Time.current)
  end

  def subscribed_to?(event_type) = enabled? && events.include?(event_type)

  def as_api_json
    {
      id:, url:, description:, enabled:, events:, signing_secret:, secret_rotated_at:, created_at:,
      last_delivery_at: webhook_deliveries.maximum(:created_at),
      recent_failure: webhook_deliveries.where(status: %w[failed retrying]).where(created_at: 24.hours.ago..).exists?
    }
  end
end
