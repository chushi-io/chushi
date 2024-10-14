# frozen_string_literal: true

class WorkspacePolicy < ApplicationPolicy
  # Named policies
  def is_admin?
    true
  end

  def can_access?
    true
  end

  def can_update?
    true
  end

  def can_destroy?
    true
  end

  def can_queue_run?
    true
  end

  def can_read_run?
    true
  end

  def can_read_variable?
    true
  end

  def can_update_variable?
    true
  end

  def can_read_state_versions?
    true
  end

  def can_read_state_outputs?
    true
  end

  def can_create_state_versions?
    true
  end

  def can_queue_apply?
    return false unless can_access_workspace?
    true
  end

  # Must be team member with lock / unlock
  def can_lock?
    true
  end

  # Must be team member with lock / unlock
  def can_unlock?
    true
  end

  # Must be team admin member
  def can_force_unlock?
    true
  end

  def can_read_settings?
    true
  end

  def can_manage_tags?
    true
  end

  def can_manage_run_tasks?
    true
  end

  def can_force_delete?
    true
  end

  def can_manage_assessments?
    true
  end

  def can_manage_ephemeral_workspaces?
    true
  end

  def can_read_assessment_results?
    true
  end

  def can_queue_destroy?
    true
  end

  # In order to create a run trigger, the user must have
  # - admin access to the specified workspace
  # - permission to read runs for the sourceable workspace
  def can_manage_run_triggers?
    true
  end

  protected

  def can_access_workspace?

    # If its coming from its agent, again, explicit access
    return agent.id == record.agent_pool.id if agent.present?
    # If the run is executing for the current workspace, explicit access
    return run.workspace.id == record.id if run.present?
    # Organization tokens can manage all workspaces
    return organization.id == record.organization_id if organization.present?

    if user.present?
      # Check if user in "owners" organization team
      team = record.organization.teams.find_by(name: 'owners')
      return true if user.teams.map(&:id).include?(team.id)

      # Lastly, check if the user is in a team attached to the current
      # Note: This only qualifies read permissions
      record.teams.each do |wsteam|
        if wsteam.users.map(&:id).include?(user.id)
          return true
        end
      end
    end

    # By default, deny access
    false
  end
end
