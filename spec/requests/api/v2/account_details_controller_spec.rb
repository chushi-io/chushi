# frozen_string_literal: true

require 'rails_helper'

describe Api::V2::AccountDetailsController do
  user = Fabricate(:user)
  token = Fabricate(:access_token, token_authable: user)

  describe 'GET /api/v2/account/details' do
    it 'responds with 403 when not authenticated' do
      verify_unauthenticated('get', api_v2_account_details_path)
    end

    it 'responds with the current users details' do
      get api_v2_account_details_path, headers: auth_headers(token)
      expect(response).to have_http_status :ok
      expect(response.body).to match_response_schema('account_details', strict: true)
    end
  end
end
