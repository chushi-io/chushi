# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe Api::V2::ModuleVersionsController do
  include JSONAPI::Deserialization
  Sidekiq::Testing.fake!

  organization = Fabricate(:organization)
  org_token = Fabricate(:access_token, token_authable: organization)

  describe 'POST /api/v2/organizations/:organization_id/registry-modules/private/:namespace/:name/:provider/versions' do
    m = Fabricate(:registry_module, organization:, namespace: organization.name)
    it 'creates a module' do
      input = {
        data: {
          type: 'registry-module-versions',
          attributes: {
            version: Faker::App.version
          }
        }
      }

      post api_v2_organization_module_versions_path(organization.name, m.namespace, m.name, m.provider),
           params: input.to_json,
           headers: auth_headers(org_token).merge(common_headers)
      expect(response).to have_http_status :created
      expect(response.body).to match_response_schema('module-version', strict: true)
      body = jsonapi_deserialize(response.parsed_body)
      expect(body['upload-url']).to be_present
    end
  end
end
