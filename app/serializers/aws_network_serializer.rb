class AwsNetworkSerializer < ApplicationSerializer
  set_type "aws-networks"

  attribute :name
  attribute :region
  attribute :cidr_block
  attribute :status
  attribute :vpc_id
  attribute :vpc_arn

  belongs_to :cloud_provider, serializer: CloudProviderSerializer, id_method_name: :name, &:cloud_provider
end
