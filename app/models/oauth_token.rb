class OauthToken < ApplicationRecord
  belongs_to :oauth_client
  before_create -> { generate_id('ot') }
end
