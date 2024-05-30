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

      @run.status = "pending"
      @run.save!

      @token = AccessToken.new
      @token.token_authable = @run
      @token.save!

      GenerateConfigurationVersionJob.perform_async(@run.id)
    end
    true
  end
end