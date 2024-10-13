# frozen_string_literal: true

class VcsConnectionsController < AuthenticatedController
  def index
    @vcs_connections = @organization.vcs_connections
  end

  def show
    @vcs_connection = @organization.vcs_connections.find(params[:id])
  end

  def new
    @vcs_connection = VcsConnection.new
  end

  def create
    @vcs_connection = @organization.vcs_connections.new(vcs_connection_params)
    if @vcs_connection.save
      flash[:info] = 'VCS Connection created'
      redirect_to @vcs_connection
    else
      flash.error = 'Failed creating VCS Connection'
      render 'new'
    end
  end

  def update; end

  def destroy
    @organization.vcs_connections.destroy(params[:id])
    flash.info = 'VCS Connection removed'
    redirect_to vcs_connections_path(@organization.name)
  end

  private

  def vcs_connection_params
    params.require(:vcs_connection).permit(:name, :provider, :github_personal_access_token)
  end
end
