# frozen_string_literal: true

Fabricator(:configuration_version) do
  source 'tfe-api'
  status 'pending'
  speculative false
  auto_queue_runs true
  provisional false
end
