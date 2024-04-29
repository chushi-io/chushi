class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization!

  def set_organization!
    redirect_to "/org_selector" and return unless session[:organization]

    @organization = current_user.organizations.find(session[:organization])
  end
end