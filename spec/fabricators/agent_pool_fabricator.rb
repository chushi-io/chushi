# frozen_string_literal: true

Fabricator(:agent_pool) do
  name { Faker::Alphanumeric.alpha(number: 10) }
end
