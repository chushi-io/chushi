# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::AppliesController do
  organization = Fabricate(:organization)
  token = Fabricate(:access_token, token_authable: organization)
  organization.teams.create(name: 'owners')
  project = Fabricate(:project, organization_id: organization.id)

  workspace = Fabricate(:workspace, organization_id: organization.id, project_id: project.id)
  apply = Fabricate(:apply)
  run = Fabricate(:run, workspace_id: workspace.id, organization_id: organization.id, apply_id: apply.id)
  describe 'GET /api/v2/applies/:apply_id' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('get', api_v2_apply_path(run.apply.external_id))
    end

    context 'when using an agent token' do
      agent = Fabricate(:agent_pool, organization_id: organization.id)
      agent_token = Fabricate(:access_token, token_authable: agent)
      workspace.update!(agent_pool_id: agent.id)

      it 'responds with apply object' do
        get api_v2_apply_path(run.apply.external_id), headers: auth_headers(agent_token)
        expect(response).to have_http_status :ok
        expect(response).to match_response_schema('apply', strict: true)
      end
    end

    context 'when using an organization token' do

    end

    context 'when user has access to workspace' do

    end

    context 'when user is in "owners" group' do

    end
    # Create a run
    # Create an
  end
end
