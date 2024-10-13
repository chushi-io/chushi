class WorkspaceTeamSerializer < ApplicationSerializer
  set_type 'team-workspaces'

  attribute :access
  attribute :runs
  attribute :variables
  attribute :state_versions
  attribute :sentinel_mocks do |_o| 'none' end
  attribute :workspace_locking
  attribute :run_tasks

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id do |object|
    object.workspace
  end

  belongs_to :team, serializer: TeamSerializer, id_method_name: :external_id do |object|
    object.team
  end
end
