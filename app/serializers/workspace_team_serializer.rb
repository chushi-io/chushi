# frozen_string_literal: true

class WorkspaceTeamSerializer < ApplicationSerializer
  set_type 'team-workspaces'

  # read, plan, write, admin, or custom
  attribute :access
  # read, plan, or apply.
  attribute :runs
  # none, read, or write.
  attribute :variables
  # none, read-outputs, read, or write.
  attribute :state_versions
  attribute :sentinel_mocks do |_o|
    'none'
  end
  # bool
  attribute :workspace_locking
  # bool
  attribute :run_tasks

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id, &:workspace

  belongs_to :team, serializer: TeamSerializer, id_method_name: :external_id, &:team
end
