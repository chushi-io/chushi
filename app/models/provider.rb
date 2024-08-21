class Provider < ApplicationRecord
  # has_one_attached :archive
  belongs_to :organization

  has_many :provider_versions
end
