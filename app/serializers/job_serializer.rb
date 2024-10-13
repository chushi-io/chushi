# frozen_string_literal: true

class JobSerializer
  include JSONAPI::Serializer

  set_key_transform :dash
  set_id :id
  set_type 'jobs'

  attribute :locked_by
  attribute :status
  attribute :locked
  attribute :operation

  belongs_to :workspace, serializer: WorkspaceSerializer, id_method_name: :external_id, &:workspace

  belongs_to :run, serializer: RunSerializer, id_method_name: :external_id, &:run

  belongs_to :agent_pool, serializer: AgentPoolSerializer, id_method_name: :external_id, &:agent_pool

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
end
