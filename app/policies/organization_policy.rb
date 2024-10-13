class OrganizationPolicy < ApplicationPolicy
  # Users that are members of an organization are expected
  # to be view a fair amount of data
  # - Teams
  # - Projects (that aren't "secret")
  def access?
    read_organization?
  end

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

  def list_memberships?
    read_organization?
  end

  def list_ssh_keys?
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

  def create_memberships?
    write_organization?
  end

  def create_workspaces?
    write_organization?
  end

  def create_ssh_keys?
    write_organization?
  end

  def create_access_token?
    write_organization?
  end

  def manage_modules?
    write_organization?
  end

  def read_organization?
    (agent.present? && agent.organization_id == record.id) ||
      (user.present? && user.organizations.map{|org| org.id}.include?(record.id)) ||
      (organization.present? && organization.id == record.id)
  end

  def read?
    read_organization?
  end

  def write_organization?
    (organization.present? && organization.id == record.id)
  end

  # Mapped permissions
  def can_destroy?
    false
  end

  def can_access_via_teams?
    true
  end

  def can_create_module?
    true
  end

  # We only allow admin organization members
  # or the organization owner
  # to create teams
  def can_create_team?
    true
  end

  def can_create_workspace?
    true
  end

  def can_manage_users?
    true
  end

  def can_manage_subscription?
    true
  end

  def can_manage_sso?
    true
  end

  def can_update_oauth?
    true
  end

  def can_update_ssh_keys?
    write_organization?
  end

  def can_update_api_token?
    true
  end

  def can_traverse?
    true
  end

  def can_start_trial?
    true
  end

  def can_update_agent_pools?
    write_organization?
  end

  def can_manage_tags?
    true
  end

  def can_manage_varsets?
    true
  end

  def can_read_varsets?
    true
  end

  def can_manage_public_providers?
    true
  end

  def can_create_provider?
    true
  end

  def can_manage_public_modules?
    true
  end

  def can_manage_custom_providers?
    true
  end

  def can_manage_run_tasks?
    true
  end

  def can_read_run_tasks?
    true
  end

  def can_create_project?
    true
  end

  # Note: Organization membership management is restricted to
  # - members of the owners team
  # - the owners team API token
  # - the organization API token
  # - users or teams with one of the Team Management permissions.
  def can_manage_memberships?
    write_organization?
  end

  ## When checking what a team can perform:
  # "manage-policies"
  # "manage-policy-overrides"
  # "manage-run-tasks"
  # "manage-workspaces"
  # "manage-vcs-settings"
  # "manage-agent-pools"
  # "manage-projects"
  # "read-projects"
  # "read-workspaces"
end