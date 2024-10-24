# frozen_string_literal: true

class ConfigurationVersion < ApplicationRecord
  def to_param
    external_id
  end

  mount_uploader :archive, ConfigurationVersionUploader

  belongs_to :workspace
  belongs_to :organization
  has_many :runs
  before_create -> { generate_id('cv') }
end
