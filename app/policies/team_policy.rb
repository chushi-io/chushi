class TeamPolicy < ApplicationPolicy
  def show?
    (organization.present? && organization.id == record.organization_id)
  end

  def update?
    (organization.present? && organization.id == record.organization_id)
  end

  def destroy?
    (organization.present? && organization.id == record.organization_id)
  end

  def create_access_token?
    (organization.present? && organization.id == record.organization_id)
  end

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