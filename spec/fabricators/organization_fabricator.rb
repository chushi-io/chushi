Fabricator(:organization) do
  name { Faker::Alphanumeric.alpha(number: 10) }
  email { Faker::Internet.email }
  organization_type "personal"
end