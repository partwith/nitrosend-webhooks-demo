class Booking < ApplicationRecord
  belongs_to :workspace
  has_many :messages, dependent: :nullify
  validates :learner_name, :email, presence: true
  def email_failed? = email_failed_at.present?

  def as_api_json
    { id:, learner_name:, email:, status:, confirmation_sent_at:, email_failed_at:, failure_reason:,
      suppressed: workspace.suppressions.exists?(email:) }
  end
end
