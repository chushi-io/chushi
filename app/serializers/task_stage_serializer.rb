# frozen_string_literal: true

class TaskStageSerializer < ApplicationSerializer
  set_type 'task-stages'

  attribute :status
  attribute :stage

  belongs_to :run, serializer: RunSerializer, id_method_name: :external_id, &:run

  has_many :task_results, serializer: TaskResultSerializer, id_method_name: :external_id, &:task_results

  has_many :policy_evaluations, serializer: PolicyEvaluationSerializer, id_method_name: :external_id do |_object|
    []
  end
end
