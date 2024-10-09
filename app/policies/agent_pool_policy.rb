class AgentPoolPolicy < ApplicationPolicy
  def show?
    (organization.present? && organization.id == record.organization_id)
  end

  def update?
    (organization.present? && organization.id == record.organization_id)
  end

  def create_access_token?
    (organization.present? && organization.id == record.organization_id)
  end
end