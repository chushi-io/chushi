class WorkspaceTaskSerializer < ApplicationSerializer
  set_type "workspace-tasks"

  attribute :enforcement_level
  attribute :stage
  attribute :stages

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id do |object|
    object.workspace
  end

  belongs_to :task, serializer: RunTaskSerializer, id_method_name: :external_id do |object|
    object.run_task
  end
end
