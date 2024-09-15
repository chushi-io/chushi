class ConfigurationVersion < ApplicationRecord
  def to_param
    external_id
  end

  has_one_attached :archive

  belongs_to :workspace
  belongs_to :organization
  before_create -> { generate_id("cv") }
  # def upload_url
  #   "#{root_url}/api/v1/configuration-versions/#{self.id}/upload"
  # end
end
