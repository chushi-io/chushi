# frozen_string_literal: true

class OpenbaoCluster < ApplicationRecord
  belongs_to :organization
  belongs_to :project
  belongs_to :virtual_network

  before_create -> { generate_id('openbao') }
end
