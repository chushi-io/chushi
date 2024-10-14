# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::OrganizationsController do
  organization = Fabricate(:organization)
  token = Fabricate(:access_token, token_authable: organization)
  organization.teams.create(name: 'owners')

  headers = {
    Authorization: "Bearer #{token.external_id.delete_prefix('at-')}.#{token.token}",
    'Content-Type': 'application/json'
  }

  describe 'GET /api/v2/organizations' do
    it 'responds with 403 when not authenticated' do
      get api_v2_organizations_path
      expect(response).to have_http_status :forbidden
    end

    it 'responds with list of users organizations' do
      # Fabricate another organization we *dont* give the user access to
      Fabricate(:organization)
      user = Fabricate(:user)
      user_token = Fabricate(:access_token, token_authable: user)
      OrganizationMembership.create(user_id: user.id, organization_id: organization.id)
      get api_v2_organizations_path, headers: {
        Authorization: "Bearer #{user_token.external_id.delete_prefix('at-')}.#{user_token.token}",
        'Content-Type': 'application/json'
      }
      expect(response).to have_http_status :ok
      # TODO: Ensure only 1 org responds
      puts response.body
    end
  end

  describe 'GET /api/v2/organizations/:id/entitlement-set' do
    it 'responds with 403 when not authenticated' do
      get api_v2_organization_entitlement_set_path(organization.name)
      expect(response).to have_http_status :forbidden
    end

    it 'responds with OK status' do
      get(api_v2_organization_entitlement_set_path(organization.name), headers:)

      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /api/v2/organizations/:id' do
    it 'responds with 403 when not authenticated' do
      get api_v2_organization_path(organization.name)
      expect(response).to have_http_status :forbidden
    end

    it 'responds with OK status' do
      get(api_v2_organization_path(organization.name), headers:)
      expect(response).to have_http_status :ok
    end

    it 'fails for non-member' do
      user = Fabricate(:user)
      user_token = Fabricate(:access_token, token_authable: user)
      get api_v2_organization_path(organization.name), headers: {
        Authorization: "Bearer #{user_token.external_id.delete_prefix('at-')}.#{user_token.token}"
      }
      expect(response).to have_http_status :not_found
    end
  end

  describe 'PUT /api/v2/organizations/:id' do
    it 'responds with 403 when not authenticated' do
      patch api_v2_organization_path(organization.name)
      expect(response).to have_http_status :forbidden
    end

    it 'responds with OK status when updating execution mode' do
      patch(api_v2_organization_path(organization.name), params: {
        'data' => {
          'type' => 'organizations',
          'id' => organization.name,
          'attributes' => {
            'default-execution-mode' => 'local'
          }
        }
      }.to_json, headers:)
      expect(response).to have_http_status :ok
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
      }.to_json, headers:)
      expect(response).to have_http_status :bad_request
    end

    # TODO: Verify that non-owners can't update the organization
    it 'disallows updates from non-owners' do
      # Create the user and add to the organization
      user = Fabricate(:user)
      user_token = Fabricate(:access_token, token_authable: user)
      OrganizationMembership.create(user_id: user.id, organization_id: organization.id)
      team = Fabricate(:team, organization_id: organization.id)
      team.users << user
      team.save!

      patch api_v2_organization_path(organization.name), params: {
        'data' => {
          'type' => 'organizations',
          'id' => organization.name,
          'attributes' => {
            'default-execution-mode' => 'local'
          }
        }
      }.to_json, headers: {
        Authorization: "Bearer #{user_token.external_id.delete_prefix('at-')}.#{user_token.token}"
      }
      expect(response).to have_http_status :not_found
    end
  end
end
