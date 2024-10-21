# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  # Users that are members of an organization are expected
  # to be view a fair amount of data
  # - Teams
  # - Projects (that aren't "secret")
  def read_organization?
    (agent.present? && agent.organization_id == record.id) ||
      (user.present? && user.organizations.map(&:id).include?(record.id)) ||
      (organization.present? && organization.id == record.id) ||
      (run.present? && run.workspace.organization_id == record.id)
  end

  def read?
    read_organization?
  end

  def write_organization?
    organization.present? && organization.id == record.id
  end

  def is_admin?
    is_organization_token || in_owners_team?(record)
  end

  # Mapped permissions
  def can_destroy?
    is_organization_token || in_owners_team?(record)
  end

  def can_access_via_teams?
    is_organization_token || in_owners_team?(record)
  end

  def can_create_module?
    is_organization_token || in_owners_team?(record)
  end

  # We only allow admin organization members
  # or the organization owner
  # to create teams
  def can_create_team?
    is_organization_token || in_owners_team?(record)
  end

  def can_create_workspace?
    is_organization_token || in_owners_team?(record) || is_org_member?(record)
  end

  def can_manage_users?
    is_organization_token || in_owners_team?(record)
  end

  def can_manage_subscription?
    is_organization_token || in_owners_team?(record)
  end

  def can_manage_sso?
    is_organization_token || in_owners_team?(record)
  end

  def can_update_oauth?
    is_organization_token || in_owners_team?(record)
  end

  def can_update_ssh_keys?
    is_organization_token || in_owners_team?(record)
  end

  def can_update_api_token?
    is_organization_token || in_owners_team?(record)
  end

  def can_traverse?
    is_organization_token || in_owners_team?(record) || is_org_member?(record)
  end

  def can_start_trial?
    is_organization_token || in_owners_team?(record)
  end

  def can_update_agent_pools?
    is_organization_token || in_owners_team?(record)
  end

  def can_manage_tags?
    is_organization_token || in_owners_team?(record)
  end

  def can_manage_varsets?
    is_organization_token || in_owners_team?(record)
  end

  def can_read_varsets?
    is_organization_token || in_owners_team?(record)
  end

  def can_manage_public_providers?
    is_organization_token || in_owners_team?(record)
  end

  def can_create_provider?
    is_organization_token || in_owners_team?(record)
  end

  def can_manage_public_modules?
    is_organization_token || in_owners_team?(record)
  end

  def can_manage_custom_providers?
    is_organization_token || in_owners_team?(record)
  end

  def can_manage_run_tasks?
    is_organization_token || in_owners_team?(record)
  end

  def can_read_run_tasks?
    is_organization_token || in_owners_team?(record)
  end

  def can_create_project?
    is_organization_token || in_owners_team?(record)
  end

  # NOTE: Organization membership management is restricted to
  # - members of the owners team
  # - the owners team API token
  # - the organization API token
  # - users or teams with one of the Team Management permissions.
  def can_manage_memberships?
    is_organization_token || in_owners_team?(record)
  end

  protected

  def is_organization_token
    organization.present? && organization.id == record.id
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
