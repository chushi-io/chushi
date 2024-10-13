# frozen_string_literal: true

class ProviderVersion < ApplicationRecord
  belongs_to :provider

  has_many :provider_version_platforms
  before_create -> { generate_id('provver') }
end
