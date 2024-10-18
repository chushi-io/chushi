# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::PlansController do
  organization = Fabricate(:organization)
  Fabricate(:access_token, token_authable: organization)
  user = Fabricate(:user)
  owners_team = organization.teams.create(name: 'owners')
  Fabricate(:team_membership, user:, team: owners_team)
  workspace = Fabricate(:workspace, organization_id: organization.id, execution_mode: 'remote')
  run = Fabricate(:run, workspace:, organization:)
  user_token = Fabricate(:access_token, token_authable: user)

  it 'shows plan information' do
    get(api_v2_plan_path(run.plan.external_id), headers: auth_headers(user_token))
    expect(response).to have_http_status :ok
    expect(response.body).to match_response_schema('plan', strict: true)
  end
end
