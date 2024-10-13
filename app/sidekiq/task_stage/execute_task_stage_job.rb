# frozen_string_literal: true

module TaskStage
  class ExecuteTaskStageJob
    include Sidekiq::Job

    def perform(*args)
      @task_stage = TaskStage.find(args.first)
      @task_stage.update(status: 'running')
      @task_stage.policy_evaluations.each do |policy_evaluation|
        PolicyEvaluation::RunPolicyEvaluationJob.perform_async(policy_evaluation.id)
      end
      @task_stage.task_results.each do |task_result|
        task_result.update(status: 'running')
        RunTaskExecutor.call(task_result)
      rescue StandardError => e
        Rails.logger.debug e.to_json
        task_result.update(status: 'errored', message: e.message)
        @task_stage.update(status: 'errored')
      end
    end
  end
end
