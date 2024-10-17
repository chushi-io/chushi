# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

describe Api::V2::ProvidersController do
  include JSONAPI::Deserialization
  Sidekiq::Testing.fake!

  organization = Fabricate(:organization)
  org_token = Fabricate(:access_token, token_authable: organization)

  describe 'POST /api/v2/organizations/:organization_id/registry' do
    it 'creates a provider' do
      input = {
        data: {
          type: 'registry-providers',
          attributes: {
            name: Faker::Alphanumeric.alpha(number: 10),
            namespace: Faker::Alphanumeric.alpha(number: 10)
          }
        }
      }
      post api_v2_organization_registry_providers_path(organization.name),
           params: input.to_json,
           headers: auth_headers(org_token).merge(common_headers)
      expect(response).to have_http_status :created
      expect(response.body).to match_response_schema('provider', strict: true)
    end
  end
end