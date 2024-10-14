# frozen_string_literal: true

Fabricator(:team) do
  name { Faker::Alphanumeric.alpha(number: 10) }
end
