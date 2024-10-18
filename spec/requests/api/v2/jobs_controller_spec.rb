# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::JobsController do
  organization = Fabricate(:organization)
  agent_pool = Fabricate(:agent_pool, organization:)
  workspace = Fabricate(:workspace, organization:, agent_pool:)
  run = Fabricate(:run, workspace:, organization:)
  job = Fabricate(:job, run:, workspace:, organization:, agent_pool:)
  agent_token = Fabricate(:access_token, token_authable: agent_pool)

  it 'returns the required links' do
    get(jobs_api_v2_agent_path(agent_pool.id), headers: auth_headers(agent_token))
    expect(response).to have_http_status :ok
    expect(response.body).to match_response_schema('jobs', strict: true)
  end
end