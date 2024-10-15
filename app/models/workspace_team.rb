# frozen_string_literal: true

class WorkspaceTeam < ApplicationRecord
  belongs_to :organization
  belongs_to :workspace
  belongs_to :team

  before_create -> { generate_id('tws') }

  def scopes
    case access
    when 'read'
      read_scopes
    when 'plan'
      plan_scopes
    when 'write'
      write_scopes
    when 'admin'
      admin_scopes
    when 'custom'
      []
    end
  end

  protected

  def read_scopes
    {
      'can-update': false,
      'can-destroy': false,
      'can-queue-run': false,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': false,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': false,
      'can-queue-apply': false,
      'can-lock': false,
      'can-unlock': false,
      'can-force-unlock': false,
      'can-read-settings': true,
      'can-manage-tags': false,
      'can-manage-run-tasks': false,
      'can-force-delete': false,
      'can-manage-assessments': false,
      'can-manage-ephemeral-workspaces': false,
      'can-read-assessment-results': true,
      'can-queue-destroy': false
    }
  end

  def plan_scopes
    {
      'can-update': false,
      'can-destroy': false,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': false,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': false,
      'can-queue-apply': false,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': false,
      'can-read-settings': true,
      'can-manage-tags': false,
      'can-manage-run-tasks': false,
      'can-force-delete': false,
      'can-manage-assessments': false,
      'can-manage-ephemeral-workspaces': false,
      'can-read-assessment-results': true,
      'can-queue-destroy': false
    }
  end

  def write_scopes
    {
      'can-update': false,
      'can-destroy': false,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': true,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': true,
      'can-queue-apply': true,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': true,
      'can-read-settings': true,
      'can-manage-tags': false,
      'can-manage-run-tasks': false,
      'can-force-delete': false,
      'can-manage-assessments': false,
      'can-manage-ephemeral-workspaces': true,
      'can-read-assessment-results': true,
      'can-queue-destroy': true
    }
  end

  def admin_scopes
    {
      'can-update': true,
      'can-destroy': true,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': true,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': true,
      'can-queue-apply': true,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': true,
      'can-read-settings': true,
      'can-manage-tags': true,
      'can-manage-run-tasks': true,
      'can-force-delete': true,
      'can-manage-assessments': true,
      'can-manage-ephemeral-workspaces': true,
      'can-read-assessment-results': true,
      'can-queue-destroy': true
    }
  end
end
