# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  # Mapped permissions
  def can_update?
    allow! if using_org_token?(record.organization)
    allow! if in_owners_team?(record.organization)
    team_has_access?(['admin'])
  end

  def can_destroy?
    allow! if using_org_token?(record.organization)
    allow! if in_owners_team?(record.organization)
    team_has_access?(['admin'])
  end

  def can_create_workspace?
    allow! if using_org_token?(record.organization)
    allow! if in_owners_team?(record.organization)
    team_has_access?(['admin'])
    # TODO: Support workspace-access?
  end

  protected

  def team_has_access?(scopes)
    return false if user.blank?

    access = false
    record.team_projects
          .select { |project_team| project_team.team.users.map(&:id).include?(user.id) }
          .each do |project_team|
      if scopes.include?(project_team.access)
        access = true
        break
      end
    end
    access
  end
end
