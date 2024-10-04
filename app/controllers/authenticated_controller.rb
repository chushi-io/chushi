class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization!

  def set_organization!
    if params[:organization]
      puts "params.organization found"
      # Ensure membership of the organization
      redirect_to organizations_path and return unless current_user.organizations.find_by(name: params[:organization])

      # TODO: If the organization has SSO configured, ensure
      # that the current user has logged in with it
      @organization = Organization.find_by(name: params[:organization])
    end
  end
end