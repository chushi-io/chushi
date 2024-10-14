# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::AgentsController do
  organization = Fabricate(:organization)
  org_token = Fabricate(:access_token, token_authable: organization)
  owner_team = organization.teams.create(name: 'owners')
  agent = Fabricate(:agent_pool, organization_id: organization.id)
  user = Fabricate(:user)
  user_token = Fabricate(:access_token, token_authable: user)
  OrganizationMembership.create(user_id: user.id, organization_id: organization.id)
  TeamMembership.create(user_id: user.id, team_id: owner_team.id)

  describe 'GET /api/v2/organizations/:organization/agent-pools' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('get', api_v2_organization_agent_pools_path(organization.name))
    end

    context 'when using organization token' do
      it 'lists agent pools' do
        get api_v2_organization_agent_pools_path(organization.name), headers: auth_headers(org_token)
        expect(response).to have_http_status :ok
        expect(response).to match_response_schema('agent_pools', strict: true)
      end
    end

    context 'when user in "owners" team' do
      it 'lists agent pools' do
        get api_v2_organization_agent_pools_path(organization.name), headers: auth_headers(user_token)
        expect(response).to have_http_status :ok
        expect(response).to match_response_schema('agent_pools', strict: true)
      end
    end
  end

  describe 'GET /api/v2/agent-pools/:agent_pool_id' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('get', api_v2_agent_path(agent.external_id))
    end

    context 'when using organization token' do
      it 'can read an agent pool' do
        get api_v2_agent_path(agent.external_id), headers: auth_headers(org_token)
        expect(response).to have_http_status :ok
        expect(response).to match_response_schema('agent_pool', strict: true)
      end
    end
  end

  describe 'POST /api/v2/organizations/:organization/agent-pools' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('post', api_v2_organization_agent_pools_path(organization.name))
    end

    context 'when using organization token' do
      it 'creates an agent pool' do
        post api_v2_organization_agent_pools_path(organization.name), params: {
          'data' => {
            'type' => 'agent-pools',
            'attributes' => {
              name: Faker::Alphanumeric.alpha(number: 10),
              'organization-scoped': false
            }
          }
        }.to_json, headers: auth_headers(org_token).merge(common_headers)
        expect(response).to have_http_status :created
      end
    end

    context 'when user in "owners" group' do
      it 'creates an agent pool' do
        # TODO: Add "allowed workspaces" when supported
        post api_v2_organization_agent_pools_path(organization.name), params: {
          'data' => {
            'type' => 'agent-pools',
            'attributes' => {
              name: Faker::Alphanumeric.alpha(number: 10),
              'organization-scoped': false
            }
          }
        }.to_json, headers: auth_headers(user_token).merge(common_headers)
        expect(response).to have_http_status :created
        expect(response).to match_response_schema('agent_pool', strict: true)
      end
    end

    context 'when user not in "owners" group' do
      it 'fails to create an agent pool' do
        non_owner_user = Fabricate(:user)
        non_owner_user_token = Fabricate(:access_token, token_authable: non_owner_user)
        OrganizationMembership.create(user_id: non_owner_user.id, organization_id: organization.id)
        post api_v2_organization_agent_pools_path(organization.name), params: {
          'data' => {
            'type' => 'agent-pools',
            'attributes' => {
              name: Faker::Alphanumeric.alpha(number: 10),
              'organization-scoped': false
            }
          }
        }.to_json, headers: auth_headers(non_owner_user_token)
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'PATCH /api/v2/agent-pools/:agent_pool_id' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('patch', api_v2_agent_path(agent.external_id))
    end
  end

  describe 'DELETE /api/v2/agent-pools/:agent_pool_id' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('delete', api_v2_agent_path(agent.external_id))
    end

    context 'when using organization token' do
      it 'deletes an agent pool' do
        deletable_agent = Fabricate(:agent_pool, organization_id: organization.id)
        delete api_v2_agent_path(deletable_agent.external_id), headers: auth_headers(org_token)
        expect(response).to have_http_status :no_content
      end
    end

    context 'when user in "owners" group' do
      it 'deletes an agent pool' do
        deletable_agent = Fabricate(:agent_pool, organization_id: organization.id)
        delete api_v2_agent_path(deletable_agent.external_id), headers: auth_headers(user_token)
        expect(response).to have_http_status :no_content
      end
    end

    context 'when user not in "owners" group' do
      it 'fails to delete an agent pool' do
        non_owner_user = Fabricate(:user)
        non_owner_user_token = Fabricate(:access_token, token_authable: non_owner_user)
        OrganizationMembership.create(user_id: non_owner_user.id, organization_id: organization.id)
        deletable_agent = Fabricate(:agent_pool, organization_id: organization.id)
        delete api_v2_agent_path(deletable_agent.external_id), headers: auth_headers(non_owner_user_token)
        expect(response).to have_http_status :not_found
      end
    end
  end
end
