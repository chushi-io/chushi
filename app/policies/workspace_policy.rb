class WorkspacePolicy < ApplicationPolicy
  def show?
    can_access_workspace
  end

  def lock?
    can_access_workspace
  end

  def update?
    can_access_workspace
  end

  def unlock?
    can_access_workspace
  end

  def force_unlock?
    can_access_workspace
  end

  def state_version_state?
    can_access_workspace
  end

  def state_version_state_json?
    can_access_workspace
  end

  def list_run_triggers?
    can_access_workspace
  end

  def create_run_triggers?
    can_access_workspace
  end

  def attach_trigger?
    can_access_workspace
  end

  def attach_team?
    (organization.present? && organization.id == record.organization_id)
  end

  def detach_team?
    (organization.present? && organization.id == record.organization_id)
  end

  def manage_tasks?
    can_access_workspace
  end

  def list_notification_configurations?
    can_access_workspace
  end

  def create_notification_configurations?
    can_access_workspace
  end

  def tags?
    can_access_workspace
  end

  def create_configuration_version?
      (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id)) ||
        (organization.present? && record.organization_id == organization.id)
  end

  def create_run?
    (agent.present? && agent.id == record.agent_pool_id) ||
      (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id)) ||
      (organization.present? && organization.id == record.organization_id)
  end

  def state_versions?
    (agent.present? && agent.id == record.agent_pool_id) ||
      (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id)) ||
      (run.present? && run.workspace_id == record.id)
  end

  # Named policies
  def is_admin?

  end

  def can_access?

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

  def can_access_workspace
    if run.present?
      return run.workspace.id == record.id
    end

    if agent.present?
      return agent.id == record.agent_pool.id
    end

    if organization.present?
      return organization.id == record.organization_id
    end

    if user.present?
      return user.organizations.map{|org| org.id}.include? record.organization_id
    end

    false
  end
end