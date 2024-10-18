# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::ProviderVersionPlatformsController do
  include JSONAPI::Deserialization
  Sidekiq::Testing.fake!

  organization = Fabricate(:organization)
  org_token = Fabricate(:access_token, token_authable: organization)

  p = Fabricate(:provider, organization:, namespace: organization.name, registry: 'private')
  v = Fabricate(:provider_version, provider: p)

  describe 'POST /api/v2/organizations/:organization_id/registry-providers/private/:namespace/:name/versions/:version/platforms' do
    it 'creates a provider version platform' do
      input = {
        data: {
          type: 'registry-provider-version-platforms',
          attributes: {
            os: 'linux',
            arch: 'amd64',
            shasum: 'abcdef123456ABCDEF',
            filename: 'tofu-provider-kubernetes_0.0.0_linux_amd64.zip'
          }
        }
      }
      post api_v2_organization_provider_version_platforms_path(organization.name, p.namespace, p.name, v.version),
           params: input.to_json,
           headers: auth_headers(org_token).merge(common_headers)
      expect(response).to have_http_status :created
      expect(response.body).to match_response_schema('provider-version-platform', strict: true)
      body = jsonapi_deserialize(response.parsed_body)
      expect(body['provider-binary-upload']).to be_falsey
    end
  end
end
