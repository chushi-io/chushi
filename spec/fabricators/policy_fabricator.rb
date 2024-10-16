# frozen_string_literal: true

Fabricator(:policy) do
  name { Faker::Alphanumeric.alpha(number: 10) }
  description { Faker::Alphanumeric.alpha(number: 10) }
  query { Faker::Alphanumeric.alpha(number: 10) }
  enforcement_level "mandatory"
end
