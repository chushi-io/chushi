# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe Api::V2::ProviderVersionsController do
  include JSONAPI::Deserialization
  Sidekiq::Testing.fake!

  organization = Fabricate(:organization)
  org_token = Fabricate(:access_token, token_authable: organization)

  describe 'POST /api/v2/organizations/:organization_id/registry-providers/private/:namespace/:name/versions' do
    it 'creates a provider version' do
      p = Fabricate(:provider, organization:, namespace: organization.name, registry: 'private')
      input = {
        data: {
          type: 'registry-provider-versions',
          attributes: {
            version: '3.1.1',
            'key-id': '32966F3FB5AC1129',
            protocols: ['5.0']
          }
        }
      }

      post api_v2_organization_provider_versions_path(organization.name, p.namespace, p.name),
           params: input.to_json,
           headers: auth_headers(org_token).merge(common_headers)
      expect(response).to have_http_status :created
      expect(response.body).to match_response_schema('provider-version', strict: true)
      body = jsonapi_deserialize(response.parsed_body)
      expect(body['shasums-upload']).to be_present
      expect(body['shasums-sig-upload']).to be_present
    end
  end
end
