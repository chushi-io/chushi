# frozen_string_literal: true

class TeamPolicy < ApplicationPolicy
  # Mapped permissions
  def can_update_membership?
    true
  end

  def can_destroy?
    true
  end

  def can_update_organization_access?
    true
  end

  def can_update_api_token?
    true
  end

  def can_update_visibility?
    true
  end
end
