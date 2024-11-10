# frozen_string_literal: true

class OpenbaoClusterSerializer < ApplicationSerializer
  set_type 'openbao-clusters'

  attribute :name
  attribute :size
  attribute :status
  attribute :version

  attribute :update_strategy
  attribute :metrics

  attribute :allowed_ip_addresses
  attribute :public_endpoint_url
  attribute :private_endpoint_url
  attribute :region

  belongs_to :organization, serializer: OrganizationSerializer, id_method_name: :name, &:organization
  belongs_to :project, serializer: ProjectSerializer, id_method_name: :external_id, &:project
  belongs_to :virtual_network, serializer: VirtualNetwork, id_method_name: :external_id, &:virtual_network
end
