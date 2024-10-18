# frozen_string_literal: true

Fabricator(:job) do
  status 'pending'
  operation 'plan'
  locked false
end
