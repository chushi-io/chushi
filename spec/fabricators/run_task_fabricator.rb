# frozen_string_literal: true

Fabricator(:run_task) do
  name { Faker::Alphanumeric.alpha(number: 10) }
  url { Faker::Internet.url }
  hmac_key { Faker::Alphanumeric.alpha(number: 10) }
  enabled true
  description { Faker::Alphanumeric.alpha(number: 10) }
end
