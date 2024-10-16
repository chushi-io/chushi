# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::WorkspacesController do
  organization = Fabricate(:organization)
  team = organization.teams.create(name: 'owners')
  org_token = Fabricate(:access_token, token_authable: organization)

  context 'when using an organization token' do
    workspace = Fabricate(:workspace, organization:)
    it_behaves_like "can create workspace", organization, org_token
    it_behaves_like "can update workspace", workspace, org_token
    it_behaves_like "can delete workspace", workspace, org_token

    it 'should be unable to lock a workspace' do
      workspace = Fabricate(:workspace, organization:, locked: false)
      post actions_lock_api_v2_workspace_path(workspace.external_id), headers: auth_headers(org_token).merge(common_headers)
      expect(response).to have_http_status :not_found
    end

    it 'should be unable to unlock a workspace' do
      workspace = Fabricate(:workspace, organization:, locked: true)
      post actions_unlock_api_v2_workspace_path(workspace.external_id), headers: auth_headers(org_token).merge(common_headers)
      expect(response).to have_http_status :not_found
    end
  end

  context 'when a member of the organization "owners" team' do
    user = Fabricate(:user)
    team.users << user
    team.save!
    user_token = Fabricate(:access_token, token_authable: user)
    workspace = Fabricate(:workspace, organization:)
    it "can create workspace", organization, user_token
    it "can update workspace", workspace, user_token
    it "can delete workspace", workspace, user_token
    it "can lock workspace", workspace, user_token
    it "can unlock workspace", workspace, user_token
    it "can force unlock workspace", workspace, user_token
  end

  context 'when a member of workspace team with "admin" permission' do
    user = Fabricate(:user)
    team = Fabricate(:team, organization:)
    team.users << user
    team.save!
    workspace = Fabricate(:workspace, organization:)
    WorkspaceTeam.create!(team:, workspace:, organization:)
    user_token = Fabricate(:access_token, token_authable: user)
    it "can create workspace", organization, user_token
    it "can update workspace", workspace, user_token
    it "can delete workspace", workspace, user_token
    it "can lock workspace", workspace, user_token
    it "can unlock workspace", workspace, user_token
    it "can force unlock workspace", workspace, user_token
  end
end
