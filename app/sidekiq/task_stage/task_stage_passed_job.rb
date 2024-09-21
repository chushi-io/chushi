class TaskStage::TaskStagePassedJob
  include Sidekiq::Job

  def perform(*args)

  end
end

PolicyEvaluationPassed      PolicyEvaluationStatus = "passed"
PolicyEvaluationFailed      PolicyEvaluationStatus = "failed"
PolicyEvaluationPending     PolicyEvaluationStatus = "pending"
PolicyEvaluationRunning     PolicyEvaluationStatus = "running"
PolicyEvaluationUnreachable PolicyEvaluationStatus = "unreachable"
PolicyEvaluationOverridden  PolicyEvaluationStatus = "overridden"
PolicyEvaluationCanceled    PolicyEvaluationStatus = "canceled"
PolicyEvaluationErrored     PolicyEvaluationStatus = "errored"