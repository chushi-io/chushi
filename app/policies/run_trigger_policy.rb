class RunTriggerPolicy < ApplicationPolicy
  def show?
    (organization.present? && organization.id == record.workspace.organization_id)
  end

  def update?
    (organization.present? && organization.id == record.workspace.organization_id)
  end

  def destroy?
    (organization.present? && organization.id == record.workspace.organization_id)
  end
end