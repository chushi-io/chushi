# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::OrganizationsController do
  organization = Fabricate(:organization)
  token = Fabricate(:access_token, token_authable: organization)
  organization.teams.create(name: 'owners')

  describe 'GET /api/v2/organizations' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('get', api_v2_organizations_path)
    end

    it 'responds with list of users organizations' do
      # Fabricate another organization we *dont* give the user access to
      other_org, = seed_org
      _, user_token = seed_user_with_teams(other_org.id)
      get api_v2_organizations_path, headers: auth_headers(user_token)
      expect(response).to have_http_status :ok
      expect(response.body).to match_response_schema('organizations', strict: true)
    end
  end

  describe 'GET /api/v2/organizations/:id/entitlement-set' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('get', api_v2_organization_entitlement_set_path(organization.name))
    end

    it 'responds with OK status' do
      get(api_v2_organization_entitlement_set_path(organization.name), headers: auth_headers(token))
      expect(response).to have_http_status :ok
      # expect(response.body).to match_response_schema('organization', strict: true)
    end
  end

  describe 'GET /api/v2/organizations/:id' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('get', api_v2_organization_path(organization.name))
    end

    it 'responds with OK status' do
      get(api_v2_organization_path(organization.name), headers: auth_headers(token))
      expect(response).to have_http_status :ok
      expect(response.body).to match_response_schema('organization', strict: true)
    end

    it 'fails for non-member' do
      user = Fabricate(:user)
      user_token = Fabricate(:access_token, token_authable: user)
      get api_v2_organization_path(organization.name), headers: auth_headers(user_token)
      expect(response).to have_http_status :not_found
    end
  end

  describe 'PUT /api/v2/organizations/:id' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('patch', api_v2_organization_path(organization.name))
    end

    it 'updates default execution mode' do
      patch(api_v2_organization_path(organization.name), params: {
        'data' => {
          'type' => 'organizations',
          'id' => organization.name,
          'attributes' => {
            'default-execution-mode' => 'local'
          }
        }
      }.to_json, headers: auth_headers(token).merge(common_headers))
      expect(response).to have_http_status :ok
      expect(response.body).to match_response_schema('organization', strict: true)
    end

    it 'disallows updating organization name' do
      patch(api_v2_organization_path(organization.name), params: {
        'data' => {
          'type' => 'organizations',
          'id' => organization.name,
          'attributes' => {
            'name' => Faker::Alphanumeric.alpha(number: 10)
          }
        }
      }.to_json, headers: auth_headers(token))
      expect(response).to have_http_status :bad_request
    end

    # TODO: Verify that non-owners can't update the organization
    it 'disallows updates from non-owners' do
      # Create the user and add to the organization
      team = Fabricate(:team, organization_id: organization.id)
      _, user_token = seed_user_with_teams(organization.id, [team])

      patch api_v2_organization_path(organization.name), params: {
        'data' => {
          'type' => 'organizations',
          'id' => organization.name,
          'attributes' => {
            'default-execution-mode' => 'local'
          }
        }
      }.to_json, headers: auth_headers(user_token)
      expect(response).to have_http_status :not_found
    end
  end
end
