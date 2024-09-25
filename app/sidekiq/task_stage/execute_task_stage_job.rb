class TaskStage::ExecuteTaskStageJob
  include Sidekiq::Job

  def perform(*args)
    @task_stage = TaskStage.find(args.first)
    @task_stage.update(status: "running")
    @task_stage.task_results.each do |task_result|
      begin
        task_result.update(status: "running")
        RunTaskExecutor.call(task_result)
      rescue StandardError => exception
        puts exception.to_json
        task_result.update(status: "errored", message: exception.message)
        @task_stage.update(status: "errored")
      end
    end
  end
end