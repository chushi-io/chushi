class RunTriggerSerializer < ApplicationSerializer
  set_type "run_triggers"

  attribute :workspace_name do |object|
    object.workspace.name
  end

  attribute :sourceable_name do |object|
    object.sourceable.name
  end

  attribute :created_at

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id do |object|
    object.workspace
  end

  belongs_to :sourceable, serializer: WorkspaceSerializer, id_method_name: :external_id do |object|
    object.sourceable
  end
end
