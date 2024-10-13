# frozen_string_literal: true

class GithubController < AuthenticatedController
  # URL callback "/?installation_id=52208041&setup_action=install&state=foo"
  def setup
    @connection = @organization.vcs_connections.where(
      github_installation_id: params[:installation_id]
    ).first
    if @connection.blank?
      @connection = @organization.vcs_connections.create(
        name: 'github-app',
        provider: 'github',
        github_installation_id: params[:installation_id]
      )
    end

    redirect_to root_path
  end
end
