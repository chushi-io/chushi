# frozen_string_literal: true

class WorkspaceTaskSerializer < ApplicationSerializer
  set_type 'workspace-tasks'

  attribute :enforcement_level
  attribute :stage
  attribute :stages

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id, &:workspace

  belongs_to :task, serializer: RunTaskSerializer, id_method_name: :external_id, &:run_task
end
