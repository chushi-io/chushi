# frozen_string_literal: true

class AgentPoolSerializer < ApplicationSerializer
  set_type 'agent-pools'

  attribute :name
  attribute :created_at
  attribute :organization_scoped
  attribute :agent_count do |_o|
    0
  end
  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
end
