class TaskStageSerializer < ApplicationSerializer
  set_type "task-stages"

  attribute :status
  attribute :stage

  belongs_to :run
end
