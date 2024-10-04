class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization!

  def set_organization!
    if params[:organization]
      puts "params.organization found"
      # Ensure membership of the organization
      redirect_to organizations_path and return unless current_user.organizations.find_by(name: params[:organization])
      @organization = Organization.find_by(name: params[:organization])
    end
  end
end