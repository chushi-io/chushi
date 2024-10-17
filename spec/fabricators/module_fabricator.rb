# frozen_string_literal: true

Fabricator(:registry_module) do
  name { Faker::Alphanumeric.alpha(number: 10) }
  namespace { Faker::Alphanumeric.alpha(number: 10) }
  provider { Faker::Alphanumeric.alpha(number: 10) }
  status 'pending'
end
