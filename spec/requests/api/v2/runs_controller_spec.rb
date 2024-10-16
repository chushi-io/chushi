# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::RunsController do
  include JSONAPI::Deserialization

  context 'when a user is in the workspace "admin" team' do
    organization = Fabricate(:organization)
    user = Fabricate(:user)
    team = Fabricate(:team, organization:, users: [user])
    workspace = Fabricate(:workspace, organization:, execution_mode: "agent")
    user_token = Fabricate(:access_token, token_authable: user)
    Fabricate(:workspace_team, team:, workspace:, organization:, access: 'admin')
    config_version = Fabricate(:configuration_version, workspace:, organization:)

    it 'fails to create for local execution mode' do
      local_workspace = Fabricate(:workspace, organization:)
      WorkspaceTeam.create!(workspace: local_workspace, team:, organization:, access: 'admin')
      headers = auth_headers(user_token).merge(common_headers)
      input = base_run_params(local_workspace, config_version)
      post(api_v2_runs_path, params: input.to_json, headers:)
      expect(response).to have_http_status :bad_request
    end

    it 'can create a plan-only run' do
      headers = auth_headers(user_token).merge(common_headers)
      input = base_run_params(workspace, config_version, {
        "plan-only": true
      })
      post(api_v2_runs_path, params: input.to_json, headers:)
      expect(response).to have_http_status :created
      expect(response).to match_json_schema('run', strict: true)
      body = jsonapi_deserialize(JSON.parse(response.body))
      expect(body['plan-only']).to be true
    end

    it 'creates task-stages for defined run tasks' do
      run_task = Fabricate(:run_task, organization:)
      Fabricate(:workspace_task, workspace:, run_task:)
      headers = auth_headers(user_token).merge(common_headers)
      input = base_run_params(workspace, config_version)
      post(api_v2_runs_path, params: input.to_json, headers:)
      expect(response).to have_http_status :created
      expect(response).to match_json_schema('run', strict: true)
      body = jsonapi_deserialize(JSON.parse(response.body))
      expect(body['task-stage_ids'].length).to be 1
      # expect(body['plan-only']).to be true
    end

    it 'creates post_plan task-stage for configured policies' do
      team = Fabricate(:team, organization:, users: [user])
      user_token = Fabricate(:access_token, token_authable: user)
      policy_set = Fabricate(:policy_set, organization:)
      Fabricate(:policy, organization:, policy_set:)
      workspace = Fabricate(:workspace, organization:, execution_mode: "agent")
      WorkspacePolicySet.create!(policy_set:, workspace:)
      Fabricate(:workspace_team, team:, workspace:, organization:, access: 'admin')
      headers = auth_headers(user_token).merge(common_headers)
      input = base_run_params(workspace, config_version)
      post(api_v2_runs_path, params: input.to_json, headers:)
      expect(response).to have_http_status :created
      expect(response).to match_json_schema('run', strict: true)
      body = jsonapi_deserialize(JSON.parse(response.body))
      expect(body['task-stage_ids'].length).to be 1
    end
  end
end