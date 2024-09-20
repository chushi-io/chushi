class TaskResult < ApplicationRecord
  belongs_to :task_stage
  belongs_to :workspace_task
  belongs_to :run_task

  before_create -> { generate_id("taskrs") }
end
