class TaskStage < ApplicationRecord
  # belongs_to :run_task
  belongs_to :run

  has_many :task_results
  has_many :policy_evaluations
  before_create -> { generate_id("ts") }
end

# pending	The initial status of a run task stage after creation.
# running	The run task stage is executing one or more tasks, which have not yet completed.
# passed	All of the run task results in the stage passed.
# failed	One more results in the run task stage failed.
# awaiting_override	The task stage is waiting for user input. Once a user manually overrides the failed run tasks, the run returns to the running state.
# errored	The run task stage has errored.
# canceled	The run task stage has been canceled.
# unreachable	The run task stage could not be executed.