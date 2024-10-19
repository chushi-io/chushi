# frozen_string_literal: true

class Plan < ApplicationRecord
  mount_uploader :plan_file, PlanFileUploader
  mount_uploader :plan_json_file, PlanJsonFileUploader
  mount_uploader :plan_structured_file, PlanStructuredFileUploader
  mount_uploader :logs, PlanLogUploader
  mount_uploader :redacted_json, PlanRedactedJsonUploader

  has_many :state_versions, through: :run
  has_one :run

  before_create -> { generate_id('plan') }
end
