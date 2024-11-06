# frozen_string_literal: true

class CloudProvider < ApplicationRecord
  belongs_to :organization

  before_create -> { generate_id('cloud-prov') }
end
