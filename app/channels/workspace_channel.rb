class WorkspaceChannel < ApplicationCable::Channel
  def subscribed = stream_for(current_workspace)
end
