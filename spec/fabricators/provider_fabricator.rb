# frozen_string_literal: true

Fabricator(:provider) do
  name { Faker::Alphanumeric.alpha(number: 10) }
  namespace { Faker::Alphanumeric.alpha(number: 10) }
end
