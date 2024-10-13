class ConfigurationVersion < ApplicationRecord
  def to_param
    external_id
  end

  mount_uploader :archive, ConfigurationVersionUploader

  belongs_to :workspace
  belongs_to :organization
  has_many :runs
  before_create -> { generate_id('cv') }
  # def upload_url
  #   "#{root_url}/api/v1/configuration-versions/#{self.id}/upload"
  # end
end
