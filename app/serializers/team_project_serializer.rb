# frozen_string_literal: true

class TeamProjectSerializer < ApplicationSerializer
  set_type 'team-projects'

  attribute :access
  attribute :project_access do |o|
    {
      settings: o.project_settings,
      teams: o.project_teams
    }
  end
  attribute :workspace_access do |o|
    {
      create: o.workspace_create,
      move: o.workspace_move,
      locking: o.workspace_locking,
      delete: o.workspace_delete,
      runs: o.workspace_runs,
      variables: o.workspace_variables,
      'state-versions': o.workspace_state_versions,
      'sentinel-mocks': false,
      'run-tasks': p.workspace_run_tasks
    }
  end

  belongs_to :project, serializer: ProjectSerializer, id_method_name: :external_id, &:project

  belongs_to :team, serializer: TeamSerializer, id_method_name: :external_id, &:team
end
