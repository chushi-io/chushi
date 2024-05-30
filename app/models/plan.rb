class Plan < ApplicationRecord
  has_one_attached :plan_file
  has_one_attached :plan_json_file
  has_one_attached :plan_structured_file
  has_one_attached :plan_log_file
  has_one :run


  # pending	The initial status of a plan once it has been created.
  # managed_queued/queued	The plan has been queued, awaiting backend service capacity to run terraform.
  # running	The plan is running.
  # errored	The plan has errored. This is a final state.
  # canceled	The plan has been canceled. This is a final state.
  # finished	The plan has completed successfully. This is a final state.
  # unreachable	The plan will not run. This is a final state.
end
