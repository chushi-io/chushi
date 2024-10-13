# frozen_string_literal: true

class UsersController < AuthenticatedController
  def index
    @users = @organization.users
  end
end
