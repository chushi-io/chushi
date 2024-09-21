class RunPolicy < ApplicationPolicy
  def show?
    can_access_run
  end

  def create?
    (agent.present? && agent.id == record.workspace.agent_id) ||
      (user.present? && user.organizations.map{|org| org.id}.include?(record.workspace.organization_id))
  end

  def update?
    can_access_run
  end

  def events?
    can_access_run
  end

  def apply?
    # We only allow users to approve runs
    (user.present? && user.organizations.map{|org| org.id}.include?(record.workspace.organization_id))
  end

  def token?
    # (agent.present? && record.workspace.agent.id == agent.id) ||
      (organization.present? && record.workspace.organization.id == organization.id)
  end
  private
  def can_access_run
    if run.present?
      return run.id == record.id
    end

    if agent.present?
      return agent.id == record.workspace.agent_id
    end

    if organization.present?
      return organization.id == record.workspace.organization_id
    end

    if user.present?
      return user.organizations.map{|org| org.id}.include? record.workspace.organization_id
    end

    false
  end
end