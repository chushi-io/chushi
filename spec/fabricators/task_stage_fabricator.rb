# frozen_string_literal: true

Fabricator(:task_stage) do
  stage 'pre_plan'
  status 'pending'
end
