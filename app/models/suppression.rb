class Suppression < ApplicationRecord
  belongs_to :workspace
  validates :email, presence: true, uniqueness: { scope: :workspace_id }
end
