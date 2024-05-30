class TaskStageSerializer
  include JSONAPI::Serializer
  set_key_transform :dash

  set_type "task-stages"

  attribute :status
  attribute :stage

  belongs_to :run
end
