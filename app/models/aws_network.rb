class AwsNetwork < ApplicationRecord
  belongs_to :cloud_provider

  before_create -> { generate_id('aws-network') }
end
