class WorkspacePolicy < ApplicationPolicy
  def show?
    can_access_workspace
  end

  def lock?
    can_access_workspace
  end

  def unlock?
    can_access_workspace
  end

  def tags?
    can_access_workspace
  end

  def create_configuration_version?
    puts agent
    puts user
    puts organization
    puts run
    (agent.present? && agent.id == record.agent_id) ||
      (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id))
  end

  def create_run?
    (agent.present? && agent.id == record.agent_id) ||
      (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id))
  end

  protected

  def can_access_workspace
    if run.present?
      return run.workspace.id == record.id
    end

    if agent.present?
      return agent.id == record.agent_id
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