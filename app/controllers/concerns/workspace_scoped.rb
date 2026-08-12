module WorkspaceScoped
  extend ActiveSupport::Concern

  included { before_action :ensure_workspace }

  private

  def ensure_workspace
    token = cookies.signed[:workspace_token]
    workspace = token && Workspace.find_by(token:)
    unless workspace
      workspace = Workspace.create!
      WorkspaceSeeder.seed(workspace, base_url: request.base_url) if defined?(WorkspaceSeeder)
      cookies.signed[:workspace_token] = { value: workspace.token, httponly: true, same_site: :lax, expires: 2.days }
    end
    workspace.touch_seen!
    Current.workspace = workspace
  end
end
