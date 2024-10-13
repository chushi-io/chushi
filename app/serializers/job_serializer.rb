class JobSerializer
  include JSONAPI::Serializer

  set_key_transform :dash
  set_id :id
  set_type 'jobs'

  attribute :locked_by
  attribute :status
  attribute :locked
  attribute :operation

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id do |object|
    object.workspace
  end

  belongs_to :run, serializer: RunSerializer, id_method_name: :external_id do |object|
    object.run
  end

  belongs_to :agent_pool, serializer: AgentPoolSerializer, id_method_name: :external_id do |object|
    object.agent_pool
  end

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name do |object|
    object.organization
  end
end
