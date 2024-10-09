class Plan < ApplicationRecord

  mount_uploader :plan_file, PlanFileUploader
  mount_uploader :plan_json_file, PlanJsonFileUploader
  mount_uploader :plan_structured_file, PlanStructuredFileUploader

  has_many :state_versions, :through => :run
  has_one :run

  before_create -> { generate_id("plan") }
end
