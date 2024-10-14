Fabricator(:team) do
  name { Faker::Alphanumeric.alpha(number: 10) }
end