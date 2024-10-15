# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  # Configure additional authorization contexts here
  # (`user` is added by default).
  #
  #   authorize :account, optional: true
  #
  # Read more about authorization context: https://actionpolicy.evilmartians.io/#/authorization_context

  authorize :user, optional: true
  authorize :agent, optional: true
  authorize :run, optional: true
  authorize :organization, optional: true

  # Define shared methods useful for most policies.
  # For example:
  #
  #  def owner?
  #    record.user_id == user.id
  #  end
  protected

  def is_org_member?(organization)
    return false if user.blank?

    user.organizations.map(&:id).include?(organization.id)
  end

  def in_owners_team?(organization)
    return false if user.blank?

    team = organization.teams.find_by(name: 'owners')
    return false if team.blank?

    user.teams.map(&:id).include?(team.id)
  end

  def using_org_token?(org)
    organization.present? && organization.id == org.id
  end
end
