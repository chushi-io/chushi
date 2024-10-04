class TaskResult::TaskResultCompletedJob
  include Sidekiq::Job

  def perform(*args)
    @task_result = TaskResult.find(args.first)
    @results = @task_result.task_stage.task_results

    @status = "passed"
    @overrideable = true
    @results.each do |task_result|
      if task_result.status == "running"
        # We still have a running task,
        # so we simply return to wait for
        # all of them to complete?
        return
      end
      if task_result.status == "errored"
        # We assume that an errored task result
        # will already have toggled the task stage
        # to errored
        return
      end

      if task_result.status == "failed"
        @status = "failed"
        if task_result.workspace_task_enforcement_level == "mandatory"
          @overrideable = false
        end
      end
    end

    # Finally, set the status of our task stage based on the
    # ultimate result of our task_results
    if @status == "passed"
      # Execute our task_stage_completed job
      @task_result.task_stage.update(status: "passed")
      TaskStage::TaskStagePassedJob.perform_async(@task_result.task_stage.id)
    else
      if @overrideable
        @task_result.task_stage.update(status: "awaiting_override")
        return
      end

      @task_result.task_stage.update(status: @status)
      TaskStage::TaskStageFailedJob.perform_async(@task_result.task_stage.id)
    end
  end
end