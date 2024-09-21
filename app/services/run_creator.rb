class RunCreator < ApplicationService
  attr_reader :run

  def initialize(run)
    @run = run
  end

  def call
    ActiveRecord::Base.transaction do
      @plan = @run.organization.plans.create(
        execution_mode: @run.workspace.execution_mode,
        status: "pending"
      )
      @run.plan = @plan
      unless @run.plan_only
        @apply = @run.organization.applies.create(
          execution_mode: @run.workspace.execution_mode
        )
        @run.apply = @apply
      end

      # TODO: This is incorrect. We don't create a
      # "task_stage" per workspace task. For any of the
      # 4 stages (pre_plan, post_plan, pre_apply, post_apply)
      # we need to check if there are any stages for that task.
      # If there are, we create the single task_stage on the run
      # and then create a "task_result" for each configured
      # run task that shares that stage
      task_stages = {
        "pre_plan" => [],
        "post_plan" => [],
        "pre_apply" => [],
        "post_apply" => [],
      }

      @run.workspace.tasks.each { |wstask|
        task_stages[wstask.stage] << wstask
      }

      task_stages.each do |stage, wstasks|
        unless wstasks.empty?
          @stage = TaskStage.new(
            stage: stage,
            status: "pending",
          )

          wstasks.each { |wstask|
            @result = TaskResult.new(
              status: "pending",
              # url: wstask.run_task.url,
              stage: stage,
            )
            @result.workspace_task = wstask
            @result.run_task = wstask.run_task
            @stage.task_results << @result
          }
          @stage.save
          @run.task_stages << @stage
        end
      end

      @run.status = "pending"
      @run.save!

      @token = AccessToken.new
      @token.token_authable = @run
      @token.save!

      RunCreatedJob.perform_async(@run.id)
      if @run.configuration_version.nil?
        GenerateConfigurationVersionJob.perform_async(@run.id)
      end
    end
    true
  end
end