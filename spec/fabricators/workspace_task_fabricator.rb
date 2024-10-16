# frozen_string_literal: true

Fabricator(:workspace_task) do
  stage "post_plan"
  stages ["post_plan"]
  enforcement_level "mandatory"
end
