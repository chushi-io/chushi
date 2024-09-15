class RunTaskSerializer < ApplicationSerializer
  set_type :tasks

  attribute :category
  attribute :name
  attribute :url
  attribute :description
  attribute :enabled
  attribute :hmac_key
end
