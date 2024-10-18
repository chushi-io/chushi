# frozen_string_literal: true

Fabricator(:provider_version) do
  protocols ['5.0']
  version { Faker::App.version }
end
