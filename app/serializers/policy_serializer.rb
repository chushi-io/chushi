# frozen_string_literal: true

class PolicySerializer < ApplicationSerializer
  set_type 'policies'

  attribute :name
  attribute :description
  attribute :kind do |_o|
    'opa'
  end
  attribute :query
  attribute :enforcement_level
  attribute :policy_set_count do |_o|
    0
  end
  attribute :updated_at
end
