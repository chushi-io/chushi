class UserPolicy < ApplicationPolicy
  def can_create_organizations?
    true
  end

  def can_change_email?
    true
  end

  def can_change_username?
    true
  end
end