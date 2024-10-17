# frozen_string_literal: true

Fabricator(:registry_module_version) do
  source 'tfe-api'
  status 'pending'
  version { Faker::App.version }
end
