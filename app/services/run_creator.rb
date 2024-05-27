class RunCreator < ApplicationService
  attr_reader :run

  def initialize(run)
    @run = run
  end

  def call
    ActiveRecord::Base.transaction do
      puts "Creating plan"
      @plan = @run.organization.plans.create(
        execution_mode: @run.workspace.execution_mode,
        status: "pending"
      )
      @run.plan = @plan
      unless @run.plan_only
        puts "Creating apply"
        @apply = @run.organization.applies.create(
          execution_mode: @run.workspace.execution_mode
        )
        @run.apply = @apply
      end

      puts "Creating run"
      @run.save!
      if needs_configuration_version
        GenerateConfigurationVersionJob.perform_async(@run.id)
      end
    end
    true
  end

  private
  def needs_configuration_version
    true
  end
end