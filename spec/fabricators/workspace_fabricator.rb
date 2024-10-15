# frozen_string_literal: true

Fabricator(:workspace) do
  name { Faker::Alphanumeric.alpha(number: 10) }
  execution_mode 'local'
end
