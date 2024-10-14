# frozen_string_literal: true

Fabricator(:run) do
  message { Faker::Alphanumeric.alpha(number: 10) }
  plan
end
