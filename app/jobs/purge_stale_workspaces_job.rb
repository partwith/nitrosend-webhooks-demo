class PurgeStaleWorkspacesJob < ApplicationJob
  def perform
    Workspace.where(last_seen_at: ...24.hours.ago).destroy_all
  end
end
