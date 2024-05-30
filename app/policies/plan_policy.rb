class PlanPolicy < ApplicationPolicy
  def show?
    if run.present?
      return run.plan.id == record.id
    end

    if agent.present?
      return agent.id == record.run.workspace.agent_id
    end

    if organization.present?
      return organization.id == record.run.workspace.organization_id
    end

    if user.present?
      return user.organizations.map{|org| org.id}.include? record.run.workspace.organization_id
    end

    false
  end

  def update?
    if run.present?
      return run.plan.id == record.id
    end

    if agent.present?
      return agent.id == record.run.workspace.agent_id
    end

    if organization.present?
      return organization.id == record.run.workspace.organization_id
    end

    if user.present?
      return user.organizations.map{|org| org.id}.include? record.run.workspace.organization_id
    end

    false
  end

  def upload?
    if run.present?
      run.plan.id == record.id
    else
      false
    end
  end
end