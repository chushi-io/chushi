# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization!
  include ActionPolicy::Controller
  authorize :user, through: :current_user

  def set_organization!
    return unless params[:organization]
    # Ensure membership of the organization
    redirect_to organizations_path and return unless current_user.organizations.find_by(name: params[:organization])

    # TODO: If the organization has SSO configured, ensure
    # that the current user has logged in with it
    @organization = Organization.find_by(name: params[:organization])

    # We don't really _need_ to do this here. Since the user is obviously
    # a member of the organization if the relationship exists. However,
    # most endpoints in the app are simply reading, and by default,
    # they can access them simply due to membership. Also, this allows
    # us to avoid explicitly authorizing every single route for the organization
    authorize! @organization, to: :read?
  end
end
