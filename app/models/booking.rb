class Booking < ApplicationRecord
  belongs_to :workspace
  has_many :messages, dependent: :nullify
  validates :learner_name, :email, presence: true
  def email_failed? = email_failed_at.present?
end
