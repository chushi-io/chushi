# frozen_string_literal: true

module ApiHelpers
  def common_headers
    {
      'Content-Type': 'application/json'
    }
  end

  def seed_org
    organization = Fabricate(:organization)
    token = Fabricate(:access_token, token_authable: organization)
    organization.teams.create(name: 'owners')
    [organization, token]
  end

  def seed_user_with_teams(organization_id, teams = [])
    user = Fabricate(:user)
    user_token = Fabricate(:access_token, token_authable: user)
    OrganizationMembership.create(user_id: user.id, organization_id:)
    teams.each do |team|
      team.users << user
      team.save!
    end
    [user, user_token]
  end
end
