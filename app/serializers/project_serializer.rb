class ProjectSerializer < ApplicationSerializer
  set_type 'projects'

  attribute :name
  attribute :description
  attribute :workspace_count
  attribute :team_count
  attribute :permissions do |_object|
    {}
  end
  attribute :auto_destroy_activity_duration

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name do |object|
    object.organization
  end
end
