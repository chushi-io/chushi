class AccessTokenPolicy < ApplicationPolicy
  def show?
    token_access?
  end

  def destroy?
    token_access?
  end

  private
  def token_access?
    case record.token_authable_type
    when "User"
      return false
    when "Organization"
      return (organization.present? && organization.id == record.token_authable_id)
    when "Agent"
      @agent = AgentPool.find(record.token_authable_id)
      return (organization.present? && organization.id == @agent.organization_id)
    when "Team"
      @team = Team.find(record.token_authable_id)
      return (organization.present? && organization.id == @team.organization_id)
    else
      return false
    end
  end
end