# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::WorkspacesController do
  context 'when using an organization token' do
    organization = Fabricate(:organization)
    org_token = Fabricate(:access_token, token_authable: organization)
    workspace = Fabricate(:workspace, organization:)

    it 'can create a workspace' do
      headers = auth_headers(org_token).merge(common_headers)
      post(api_v2_organization_workspaces_path(organization.name), params: workspace_params.to_json, headers:)
      expect(response).to have_http_status :created
      expect(response).to match_json_schema('workspace', strict: true)
    end

    it_behaves_like 'can update workspace', workspace, org_token
    it_behaves_like 'can delete workspace', workspace, org_token

    it 'is unable to lock a workspace' do
      headers = auth_headers(org_token).merge(common_headers)
      workspace = Fabricate(:workspace, organization:, locked: false)
      post(actions_lock_api_v2_workspace_path(workspace.external_id), headers:)
      expect(response).to have_http_status :not_found
    end

    it 'is unable to unlock a workspace' do
      headers = auth_headers(org_token).merge(common_headers)
      workspace = Fabricate(:workspace, organization:, locked: true)
      post(actions_unlock_api_v2_workspace_path(workspace.external_id), headers:)
      expect(response).to have_http_status :not_found
    end
  end

  context 'when a member of the organization "owners" team' do
    organization = Fabricate(:organization)
    user = Fabricate(:user)
    team = Fabricate(:team, organization:, name: 'owners')
    Fabricate(:team_membership, user:, team:)
    Fabricate(:workspace, organization:)
    user_token = Fabricate(:access_token, token_authable: user)

    it 'can create a workspace' do
      headers = auth_headers(user_token).merge(common_headers)
      post(api_v2_organization_workspaces_path(organization.name), params: workspace_params.to_json, headers:)
      expect(response).to have_http_status :created
      expect(response).to match_json_schema('workspace', strict: true)
    end

    # it 'can update workspace', workspace, user_token
    # it 'can delete workspace', workspace, user_token
    # it 'can lock workspace', workspace, user_token
    # it 'can unlock workspace', workspace, user_token
    # it 'can force unlock workspace', workspace, user_token
  end

  context 'when a member of workspace team with "admin" permission' do
    organization = Fabricate(:organization)
    user = Fabricate(:user)
    team = Fabricate(:team, organization:, users: [user])
    workspace = Fabricate(:workspace, organization:)
    user_token = Fabricate(:access_token, token_authable: user)
    Fabricate(:workspace_team, team:, workspace:, organization:, access: 'admin')

    it 'is unable to create a workspace' do
      headers = auth_headers(user_token).merge(common_headers)
      post(api_v2_organization_workspaces_path(organization.name), params: workspace_params.to_json, headers:)
      expect(response).to have_http_status :not_found
    end

    # it 'can update workspace', workspace, user_token
    # it 'can delete workspace', workspace, user_token
    # it 'can lock workspace', workspace, user_token
    # it 'can unlock workspace', workspace, user_token
    # it 'can force unlock workspace', workspace, user_token
  end

  context 'when a user is member of a project with "admin" access' do
    organization = Fabricate(:organization)

    user = Fabricate(:user)
    project = Fabricate(:project, organization:)
    team = Fabricate(:team, organization:)
    Fabricate(:team_membership, team:, user:)
    Fabricate(:team_project, team:, project:, organization:, access: 'admin')
    Fabricate(:workspace, organization:, project:)
    user_token = Fabricate(:access_token, token_authable: user)

    it 'can create a workspace' do
      input = workspace_params(project.external_id)
      headers = auth_headers(user_token).merge(common_headers)
      post(api_v2_organization_workspaces_path(organization.name), params: input.to_json, headers:)
      expect(response).to have_http_status :created
      expect(response).to match_json_schema('workspace', strict: true)
    end

    # it 'can update workspace', workspace, user_token
    # it 'can delete workspace', workspace, user_token
    # it 'can lock workspace', workspace, user_token
    # it 'can unlock workspace', workspace, user_token
    # it 'can force unlock workspace', workspace, user_token
  end

  context 'when a user is member of a project with "maintain" access' do
    organization = Fabricate(:organization)
    user = Fabricate(:user)
    project = Fabricate(:project, organization:)
    team = Fabricate(:team, organization:)
    Fabricate(:team_membership, team:, user:)
    Fabricate(:team_project, team:, project:, organization:, access: 'maintain')
    Fabricate(:workspace, organization:, project:)
    user_token = Fabricate(:access_token, token_authable: user)

    it 'cannot create a workspace' do
      input = workspace_params(project.external_id)
      headers = auth_headers(user_token).merge(common_headers)
      post(api_v2_organization_workspaces_path(organization.name), params: input.to_json, headers:)
      expect(response).to have_http_status :not_found
    end
  end
end
