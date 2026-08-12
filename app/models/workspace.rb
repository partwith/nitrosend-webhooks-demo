class Workspace < ApplicationRecord
  # Associations from later tasks - uncomment when models are created
  # has_many :bookings, dependent: :destroy
  # has_many :messages, dependent: :destroy
  # has_many :suppressions, dependent: :destroy
  # has_many :webhook_endpoints, dependent: :destroy
  # has_many :webhook_events, dependent: :destroy
  # has_many :webhook_deliveries, dependent: :destroy

  before_create { self.token ||= "ws_#{SecureRandom.alphanumeric(24).downcase}" }

  def touch_seen! = update_column(:last_seen_at, Time.current)
end
