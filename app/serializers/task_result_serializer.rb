class TaskResultSerializer < ApplicationSerializer
  set_type "task-results"

  attribute :message
  attribute :status
  attribute :status_timestamps
  attribute :url
  attribute :created_at
  attribute :updated_at
  # The organization run task
  attribute :task_id do |object|
    attribute.run_task.external_id
  end
  attribute :task_name do |object|
    object.run_task.name
  end
  attribute :task_url do |object|
    object.run_task.url
  end

  attribute :stage
  attribute :is_speculative
  attribute :workspace_task_id do |object|
    object.workspace.external_id
  end
  attribute :workspace_task_enforcement_level do |object|
    object.workspace.enforcement_level
  end

  belongs_to :task_stage, serializer: TaskStageSerializer, id_method_name: :external_id do |object|
    object.task_stage
  end
end
