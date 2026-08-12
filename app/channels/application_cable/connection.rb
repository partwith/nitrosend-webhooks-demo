module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_workspace

    def connect
      token = cookies.signed[:workspace_token]
      self.current_workspace = Workspace.find_by(token:) || reject_unauthorized_connection
    end
  end
end
