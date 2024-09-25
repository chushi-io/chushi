class ConfigurationVersionPolicy < ApplicationPolicy
  def show?
    (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id)) ||
      (organization.present? && organization.id == record.workspace.organization_id) ||
      (agent.present? && agent.id == record.workspace.agent_pool_id)
  end

  def download?
    (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id)) ||
      (agent.present? && agent.id == record.workspace.agent_pool_id) ||
      (organization.present? && organization.id == record.workspace.organization_id) ||
      (run.present? && run.workspace.id == record.workspace.id)
  end

  def upload?
    (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id))
  end
end