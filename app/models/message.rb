class Message < ApplicationRecord
  belongs_to :workspace
  belongs_to :booking, optional: true
  has_many :webhook_events, dependent: :nullify
  validates :recipient, presence: true
  before_create { self.message_id ||= "msg_#{SecureRandom.alphanumeric(20).downcase}" }
end
