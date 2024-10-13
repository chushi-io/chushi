# frozen_string_literal: true

class RunPolicy < ApplicationPolicy
  def token?
    (agent.present? && record.workspace.agent_pool.id == agent.id) ||
      (organization.present? && record.workspace.organization.id == organization.id)
  end

  # Mapped permissions
  def can_apply?
    true
  end

  def can_cancel?
    true
  end

  def can_comment?
    true
  end

  def can_discard?
    true
  end

  def can_force_execute?
    true
  end

  def can_force_cancel?
    true
  end

  def can_override_policy_check?
    true
  end

  private

  def can_access_run
    return run.id == record.id if run.present?

    return agent.id == record.workspace.agent_pool_id if agent.present?

    return organization.id == record.workspace.organization_id if organization.present?

    return user.organizations.map(&:id).include? record.workspace.organization_id if user.present?

    false
  end
end
