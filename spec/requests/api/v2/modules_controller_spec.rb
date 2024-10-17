# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::ModulesController do
  organization = Fabricate(:organization)
  org_token = Fabricate(:access_token, token_authable: organization)

  describe 'GET /api/v2/organizations/:name/registry-modules' do
    it 'lists registered modules' do
      Fabricate(:registry_module, organization:)
      get api_v2_organization_registry_modules_path(organization.name), headers: auth_headers(org_token)
      expect(response).to have_http_status :ok
      expect(response).to match_response_schema('modules', strict: true)
    end

    it 'gets an individual module' do
      m = Fabricate(:registry_module, organization:)
      get api_v2_organization_show_module_path(organization.name, m.namespace, m.name, m.provider), headers: auth_headers(org_token)
      expect(response).to have_http_status :ok
      expect(response).to match_response_schema('module', strict: true)
    end

    it 'creates a module' do
      input = {
        data: {
          type: 'registry-modules',
          attributes: {
            name: Faker::Alphanumeric.alpha(number: 10),
            provider: Faker::Alphanumeric.alpha(number: 10),
            'registry-name': 'private'
          }
        }
      }
      post api_v2_organization_registry_modules_path(organization.name),
           params: input.to_json,
           headers: auth_headers(org_token).merge(common_headers)
      expect(response).to have_http_status :created
      expect(response.body).to match_response_schema('module', strict: true)
    end
  end
end
