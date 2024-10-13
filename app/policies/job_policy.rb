# frozen_string_literal: true

class JobPolicy < ApplicationPolicy
  def index?
    can_manage_job?
  end

  def show?
    can_manage_job?
  end

  def lock?
    can_manage_job?
  end

  def unlock?
    can_manage_job?
  end

  def update?
    can_manage_job?
  end

  def destroy?
    can_manage_job?
  end

  private

  def can_manage_job?
    agent.present? && agent.id == record.agent_pool_id
  end
end
