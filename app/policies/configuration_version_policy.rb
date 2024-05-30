class ConfigurationVersionPolicy < ApplicationPolicy
  def show?
    (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id)) ||
      (agent.present? && agent.id == record.workspace.agent_id)
  end

  def download?
    (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id)) ||
      (agent.present? && agent.id == record.workspace.agent_id) ||
      (organization.present? && organization.id == record.workspace.organization_id)
  end

  def upload?
    (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id))
  end
end