# frozen_string_literal: true

class RunStatusUpdater < ApplicationService
  attr_reader :run

  def initialize(run)
    super
    @run = run
  end

  def update_plan_status(status)
    ActiveRecord::Base.transaction do
      @run.plan.update(status:)
      case @run.plan.status
      when 'finished'
        if @run.plan_only
          @run.update(status: 'planned_and_finished')
        else
          @run.update(status: 'planned_and_saved')
        end
      when 'errored'
        @run.update(status: 'errored')
      when 'canceled'
        @run.update(status: 'canceled')
      when 'running'
        @run.update(status: 'planning')
      else
        next
      end
    end
    true
  end

  def update_apply_status(status)
    ActiveRecord::Base.transaction do
      @run.apply.update(status:)
      case @run.apply.status
      when 'finished'
        @run.update(status: 'applied')
      when 'errored'
        @run.update(status: 'errored')
      when 'canceled'
        @run.update(status: 'canceled')
      when 'running'
        @run.update(status: 'applying')
      else
        next
      end
    end
    true
  end

  def update_run_status(status)
    @run.update(status:)
  end
end
