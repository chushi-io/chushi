# frozen_string_literal: true

class VirtualNetworkSerializer < ApplicationSerializer
  set_type 'virtual-networks'

  attribute :cloud
  attribute :region
  attribute :cidr_block

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
end
