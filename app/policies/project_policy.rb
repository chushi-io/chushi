class ProjectPolicy < ApplicationPolicy
  # Mapped permissions
  def can_update?
    (organization.present? && organization.id == record.organization_id)
  end

  def can_destroy?
    true
  end

  def can_create_workspace?

  end
end