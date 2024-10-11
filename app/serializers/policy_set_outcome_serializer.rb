class PolicySetOutcomeSerializer < ApplicationSerializer
  set_type "policy-set-outcomes"

  attribute :outcomes
  attribute :error
  attribute :overrideable
  attribute :policy_set_name
  attribute :policy_set_description
  attribute :result_count
  attribute :policy_tool_version

  belongs_to :policy_evaluation, serializer: PolicyEvaluationSerializer, id_method_name: :external_id do |object|
    object.policy_evaluation
  end
end
