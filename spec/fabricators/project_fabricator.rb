# frozen_string_literal: true

Fabricator(:project) do
  name { Faker::Alphanumeric.alpha(number: 10) }
end
