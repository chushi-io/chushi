class TaskStageSerializer < ApplicationSerializer
  set_type 'task-stages'

  attribute :status
  attribute :stage

  belongs_to :run, serializer: RunSerializer, id_method_name: :external_id do |object|
    object.run
  end

  has_many :task_results, serializer: TaskResultSerializer, id_method_name: :external_id do |object|
    object.task_results
  end

  has_many :policy_evaluations, serializer: PolicyEvaluationSerializer, id_method_name: :external_id do |_object|
    []
  end
end
