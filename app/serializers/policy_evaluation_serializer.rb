class PolicyEvaluationSerializer < ApplicationSerializer
  set_type "policy-evaluations"

  attribute :status
  attribute :policy_kind
  attribute :policy_tool_version
  attribute :result_count
  attribute :status_timestamps
  attribute :created_at
  attribute :updated_at

  belongs_to :policy_attachable, serializer: TaskStageSerializer, id_method_name: :external_id do |object|
    object.task_stage
  end
end
