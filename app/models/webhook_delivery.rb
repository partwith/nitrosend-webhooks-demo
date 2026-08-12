class WebhookDelivery < ApplicationRecord
  STATUSES = %w[pending delivering delivered retrying failed].freeze
  belongs_to :workspace
  belongs_to :webhook_endpoint
  belongs_to :webhook_event
  has_many :delivery_attempts, -> { order(:number) }, dependent: :destroy
  validates :status, inclusion: { in: STATUSES }
end
