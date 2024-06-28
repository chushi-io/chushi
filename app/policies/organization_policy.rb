class OrganizationPolicy < ApplicationPolicy
  def tags?
    false
  end

  def queue?
    agent.present?
  end

  def entitlements?
    true
  end

  def list_workspaces?
    (agent.present? && agent.organization_id == record.id) ||
      (user.present? && user.organizations.map{|org| org.id}.include?(record.id)) ||
      (organization.present? && organization.id == record.id)
  end
end