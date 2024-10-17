# frozen_string_literal: true

Fabricator(:policy_set) do
  name { Faker::Alphanumeric.alpha(number: 10) }
  description { Faker::Alphanumeric.alpha(number: 10) }
  global false
  kind 'opa'
  overridable false
end
