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

  def show?
    read_organization?
  end

  def update?
    write_organization?
  end

  def list_workspaces?
    read_organization?
  end

  def list_agent_pools?
    read_organization?
  end

  def list_projects?
    read_organization?
  end

  def list_teams?
    read_organization?
  end

  def list_team_projects?
    read_organization?
  end
  def list_variable_sets?
    read_organization?
  end

  def create_agent_pools?
    write_organization?
  end

  def create_run_tasks?
    write_organization?
  end

  def create_projects?
    write_organization?
  end

  def create_teams?
    write_organization?
  end

  def create_variable_sets?
    write_organization?
  end

  def create_team_projects?
    write_organization?
  end

  def read_organization?
    (agent.present? && agent.organization_id == record.id) ||
      (user.present? && user.organizations.map{|org| org.id}.include?(record.id)) ||
      (organization.present? && organization.id == record.id)
  end

  def write_organization?
    (organization.present? && organization.id == record.id)
  end
end