class SshKeyPolicy < ApplicationPolicy
  def show?
    (organization.present? && organization.id == record.organization_id)
  end

  def update?
    (organization.present? && organization.id == record.organization_id)
  end

  def destroy?
    (organization.present? && organization.id == record.organization_id)
  end
end