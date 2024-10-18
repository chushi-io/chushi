# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::ConfigurationVersionsController do
  # Create the organization
  organization = Fabricate(:organization)
  Fabricate(:access_token, token_authable: organization)
  owners_team = organization.teams.create(name: 'owners')

  # Create the project, workspace, and setup access
  project = Fabricate(:project, organization_id: organization.id)
  workspace = Fabricate(:workspace, organization_id: organization.id, project_id: project.id)
  team = Fabricate(:team, organization_id: organization.id)
  WorkspaceTeam.create(workspace_id: workspace.id, organization:, team_id: team.id, access: 'read')
  version = Fabricate(:configuration_version, workspace_id: workspace.id, organization_id: organization.id)

  # You need read runs permission to list and view configuration versions for a workspace
  describe 'GET /api/v2/configuration-versions/:id' do
    it 'responds with 403 when not authentiqcated' do
      verify_unauthenticated('get', api_v2_configuration_version_path(version.external_id))
    end

    context 'when using a token for user with team access' do
      it 'responds with the configuration version' do
        _, user_token = seed_user_with_teams(organization.id, [team])
        get api_v2_configuration_version_path(version.external_id), headers: auth_headers(user_token)
        expect(response).to have_http_status :ok
        expect(response.body).to match_response_schema('configuration-version', strict: true)
      end
    end

    context 'when using a token for user without team access' do
      it 'fails with a 404' do
        _, user_token = seed_user_with_teams(organization.id, [])
        get api_v2_configuration_version_path(version.external_id), headers: auth_headers(user_token)
        expect(response).to have_http_status :not_found
      end
    end

    context 'when using an agent token' do
      it 'fails with a 404' do
        verify_unauthenticated('get', api_v2_configuration_version_path(version.external_id))
      end
    end
  end

  # and you need queue plans permission to create new configuration versions
  describe 'POST /api/v2/workspaces/:id/configuration-versions' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('post', configuration_versions_api_v2_workspace_path(workspace.external_id))
    end

    context 'when user is in the "owners" group' do
      user = Fabricate(:user)
      Fabricate(:team_membership, user:, team: owners_team)
      workspace  = Fabricate(:workspace, organization:, execution_mode: 'agent')
      user_token = Fabricate(:access_token, token_authable: user)

      it 'can create a configuration' do
        input = {
          data: {
            type: 'configuration-versions',
            attributes: {
              'auto-queue-runs': false,
              provisional: false,
              speculative: true
            }
          }
        }
        post configuration_versions_api_v2_workspace_path(workspace.external_id),
             params: input.to_json,
             headers: auth_headers(user_token).merge(common_headers)
        expect(response).to have_http_status :created
        expect(response.body).to match_response_schema('configuration-version', strict: true)
      end
    end
  end

  describe 'GET /api/v2/configuration-versions/:id/download' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('get', download_api_v2_configuration_version_path(version.external_id))
    end
  end
end
