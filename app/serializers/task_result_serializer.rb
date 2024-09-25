class TaskResultSerializer < ApplicationSerializer
  set_type "task-results"

  attribute :message
  attribute :status
  attribute :status_timestamps
  attribute :url
  attribute :created_at
  attribute :updated_at
  # The organization run task
  attribute :task_id
  attribute :task_name
  attribute :task_url

  attribute :stage
  attribute :is_speculative
  attribute :workspace_task_id
  attribute :workspace_task_enforcement_level

  belongs_to :task_stage, serializer: TaskStageSerializer, id_method_name: :external_id do |object|
    object.task_stage
  end
end
