# frozen_string_literal: true

class Provider < ApplicationRecord
  belongs_to :organization
  has_many :provider_versions
  before_create -> { generate_id('prov') }
end
