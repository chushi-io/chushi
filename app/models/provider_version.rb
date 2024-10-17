# frozen_string_literal: true

class ProviderVersion < ApplicationRecord
  belongs_to :provider

  mount_uploader :shasums, ProviderVersionShasumsUploader
  mount_uploader :shasums_sig, ProviderVersionShasumsSigUploader
  has_many :provider_version_platforms
  before_create -> { generate_id('provver') }
end
