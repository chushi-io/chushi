class Apply < ApplicationRecord
  has_one :run

  has_many :state_versions

  # pending	The initial status of a apply once it has been created.
  # managed_queued/queued	The apply has been queued, awaiting backend service capacity to run terraform.
  # running	The apply is running.
  # errored	The apply has errored. This is a final state.
  # canceled	The apply has been canceled. This is a final state.
  # finished	The apply has completed successfully. This is a final state.
  # unreachable	The apply will not run. This is a final state.
end
