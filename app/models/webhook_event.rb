class WebhookEvent < ApplicationRecord
  belongs_to :workspace
  belongs_to :message, optional: true
  has_many :webhook_deliveries, dependent: :destroy
  validates :event_type, inclusion: { in: WebhookEndpoint::EVENT_TYPES }
end
