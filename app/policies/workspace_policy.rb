# frozen_string_literal: true

class WorkspacePolicy < ApplicationPolicy
  # Named policies
  def is_admin?
    allow! if using_org_token?(record.organization)
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin])
  end

  def can_access?
    allow! if using_org_token?(record.organization)
    allow! if in_owners_team?(record.organization)
    allow! if is_agent?
    allow! if check_project_access?(nil)
  end

  def can_update?
    allow! if using_org_token?(record.organization)
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-update')
  end

  def can_destroy?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-destroy')
  end

  def can_queue_run?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain write read])
    check_team_access('can-queue-run')
  end

  def can_read_run?
    allow! if in_owners_team?(record.organization)
    allow! if is_agent?
    allow! if is_run_for_workspace?
    allow! if check_project_access?(nil)
    check_team_access('can-read-run')
  end

  def can_read_variable?
    allow! if in_owners_team?(record.organization)
    allow! if is_agent?
    allow! if check_project_access?(nil)
    check_team_access('can-read-variable')
  end

  def can_update_variable?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-update-variable')
  end

  def can_read_state_versions?
    allow! if in_owners_team?(record.organization)
    allow! if is_run_for_workspace?
    allow! if check_project_access?(nil)
    check_team_access('can-read-state-versions')
  end

  def can_read_state_outputs?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(nil)
    check_team_access('can-read-state-outputs')
  end

  def can_create_state_versions?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain write])
    check_team_access('can-create-state-versions')
  end

  def can_queue_apply?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain write])
    check_team_access('can-queue-apply')
  end

  # Must be team member with lock / unlock
  def can_lock?
    allow! if in_owners_team?(record.organization)
    allow! if is_run_for_workspace?
    allow! if check_project_access?(%w[admin maintain write])
    check_team_access('can-lock')
  end

  # Must be team member with lock / unlock
  def can_unlock?
    allow! if in_owners_team?(record.organization)
    allow! if is_run_for_workspace?
    allow! if check_project_access?(%w[admin maintain write])
    check_team_access('can-unlock')
  end

  # Must be team admin member
  def can_force_unlock?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-force-unlock')
  end

  def can_read_settings?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(nil)
    check_team_access('can-read-settings')
  end

  def can_manage_tags?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-manage-tags')
  end

  def can_manage_run_tasks?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-manage-run-tasks')
  end

  def can_force_delete?
    allow! if using_org_token?(record.organization)
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-force-delete')
  end

  def can_manage_assessments?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-manage-assessments')
  end

  def can_manage_ephemeral_workspaces?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-manage-ephemeral-workspaces')
  end

  def can_read_assessment_results?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(nil)
    check_team_access('can-read-assessment-results')
  end

  def can_queue_destroy?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain write])
    check_team_access('can-queue-destroy')
  end

  # In order to create a run trigger, the user must have
  # - admin access to the specified workspace
  # - permission to read runs for the sourceable workspace
  def can_manage_run_triggers?
    allow! if in_owners_team?(record.organization)
    allow! if check_project_access?(%w[admin maintain])
    check_team_access('can-manage-run-triggers')
  end

  def is_agent?
    agent.present? && agent.id == record.agent_pool_id
  end

  protected

  def check_team_access(scope)
    return false if user.blank?

    record.workspace_teams
          .select { |wsteam| wsteam.team.users.map(&:id).include?(user.id) }
          .any? { |wsteam| wsteam.scopes[scope.to_sym] == true }
  end

  def check_project_access?(scopes)
    return false if user.blank?
    return false if record.project.nil?

    local_projects = record.project.team_projects
                           .select { |project_team| project_team.team.users.map(&:id).include?(user.id) }
    return local_projects.length.positive? if scopes.nil?

    local_projects.any? { |project_team| scopes.include?(project_team.access) }
  end

  def is_run_for_workspace?
    return false if run.blank?

    run.workspace.id == record.id
  end

  def can_access_workspace?
    # If the run is executing for the current workspace, explicit access
    return run.workspace.id == record.id if run.present?
    # Organization tokens can manage all workspaces
    return organization.id == record.organization_id if organization.present?

    if user.present?
      # Lastly, check if the user is in a team attached to the current
      # Note: This only qualifies read permissions
      record.teams.each do |wsteam|
        return true if wsteam.users.map(&:id).include?(user.id)
      end
    end

    # By default, deny access
    false
  end
end
