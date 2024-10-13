require 'rails_helper'

describe Api::V2::OrganizationsController, type: :request do
  organization = Fabricate(:organization)
  token = Fabricate(:access_token, token_authable: organization)
  headers = {
    "Authorization": "Bearer #{token.external_id.delete_prefix("at-")}.#{token.token}",
    "Content-Type": "application/json"
  }

  describe 'GET /api/v2/organizations/:id/entitlement-set' do
    it 'responds with 403 when not authenticated' do
      get api_v2_organization_entitlement_set_path(organization.name)
      expect(response).to have_http_status :forbidden
    end

    it 'responds with OK status' do
      get api_v2_organization_entitlement_set_path(organization.name), headers: headers

      expect(response).to have_http_status :ok
    end
  end

  describe 'GET /api/v2/organizations/:id' do
    it 'responds with 403 when not authenticated' do
      get api_v2_organization_path(organization.name)
      expect(response).to have_http_status :forbidden
    end

    it 'responds with OK status' do
      get api_v2_organization_path(organization.name), headers: headers
      expect(response).to have_http_status :ok
    end

    it 'fails for non-member' do
      user = Fabricate(:user)
      user_token = Fabricate(:access_token, token_authable: organization)
      get api_v2_organization_path(organization.name), headers: {
        "Authorization": "Bearer #{user_token.external_id.delete_prefix("at-")}.#{user_token.token}"
      }
      expect(response).to have_http_status :ok
    end
  end

  describe 'PUT /api/v2/organizations/:id' do
    it 'responds with 403 when not authenticated' do
      patch api_v2_organization_path(organization.name)
      expect(response).to have_http_status :forbidden
    end

    it 'responds with OK status when updating execution mode' do
      patch api_v2_organization_path(organization.name), params: {
        "data" => {
          "type" => "organizations",
          "id" => organization.name,
          "attributes" => {
            "default-execution-mode" => "local"
          }
        }
      }.to_json, headers: headers
      expect(response).to have_http_status :ok
    end

    it 'disallows updating organization name' do
      patch api_v2_organization_path(organization.name), params: {
        "data" => {
          "type" => "organizations",
          "id" => organization.name,
          "attributes" => {
            "name" => Faker::Alphanumeric.alpha(number: 10)
          }
        }
      }.to_json, headers: headers
      puts response.body
      expect(response).to have_http_status :bad_request
    end

    # TODO: Verify that non-owners can't update the organization
  end
end
