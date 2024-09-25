class TaskStage::TaskStagePassedJob
  include Sidekiq::Job

  def perform(*args)
    puts "Looks like our task stage passed!!!"
    @task_stage = TaskStage.find(args.first)
    case @task_stage.stage
    when "pre_plan"
      @task_stage.run.update(status: "pre_plan_completed")
      RunStage::PrePlanCompletedJob.perform_async(@task_stage.run.id)
    when "post_plan"
      @task_stage.run.update(status: "post_plan_completed")
    when "pre_apply"
      @task_stage.run.update(status: "pre_apply_completed")
    when "post_apply"
      @task_stage.run.update(status: "post_apply_completed")
    else
      puts "Invalid task stage: #{@task_stage.stage}"
    end
  end
end
