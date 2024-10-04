class UsersController < AuthenticatedController
  def index
    @users = @organization.users
  end
end
