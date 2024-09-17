class TeamProjectSerializer < ApplicationSerializer
  set_type "team-projects"

  attribute :access
  attribute :project_access do |o| {} end
  attribute :workspace_access do |o| {} end

  belongs_to :project, serializer: ProjectSerializer, id_method_name: :external_id do |object|
    object.project
  end

  belongs_to :team, serializer: TeamSerializer, id_method_name: :external_id do |object|
    object.team
  end
end
