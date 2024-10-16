# frozen_string_literal: true

class RunCreator < ApplicationService
  attr_reader :run

  # Rubocop is disabled here, otherwise
  # the call to super causes errors on initialize
  # rubocop:disable Lint/MissingSuper
  def initialize(run)
    @run = run
  end
  # rubocop:enable Lint/MissingSuper

  def call
    ActiveRecord::Base.transaction do
      @plan = @run.organization.plans.create(
        execution_mode: @run.workspace.execution_mode,
        status: 'pending'
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
        'pre_plan' => [],
        'post_plan' => [],
        'pre_apply' => [],
        'post_apply' => []
      }

      @run.workspace.tasks.each do |wstask|
        task_stages[wstask.stage] << wstask
      end

      task_stages.each do |stage, wstasks|
        unless wstasks.any? || (stage == 'post_plan' && run.workspace.policy_sets.any?)
          next
        end
        @stage = TaskStage.new(
          stage:,
          status: 'pending'
        )

        unless wstasks.empty?
          wstasks.each do |wstask|
            @result = TaskResult.new(
              status: 'pending',
              # url: wstask.run_task.url,
              stage:,
              task_id: wstask.run_task.external_id,
              task_name: wstask.run_task.name,
              task_url: wstask.run_task.url,
              workspace_task_id: wstask.external_id,
              workspace_task_enforcement_level: wstask.enforcement_level
            )
            @stage.task_results << @result
          end
        end

        unless @run.workspace.policy_sets.empty?
          @run.workspace.policy_sets.each do |policy_set|
            @stage.policy_evaluations << PolicyEvaluation.new(
              policy_kind: 'opa',
              policy_set_id: policy_set.external_id
            )
          end
        end
        @stage.save
        @run.task_stages << @stage
      end
      @run.status = 'pending'
      @run.save!

      @token = AccessToken.new
      @token.token_authable = @run
      @token.save!

      RunCreatedJob.perform_async(@run.id)
      GenerateConfigurationVersionJob.perform_async(@run.id) if @run.configuration_version.nil?
    end
    true
  end
end
