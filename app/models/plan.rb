class Plan < ApplicationRecord
  has_one_attached :plan_file
  has_one_attached :plan_json_file
  has_one_attached :plan_structured_file
  has_one_attached :plan_log_file

  has_many :state_versions, :through => :run
  has_one :run

  before_create -> { generate_id("plan") }
end
