# frozen_string_literal: true

class ProviderVersionPlatform < ApplicationRecord
  belongs_to :provider_version

  mount_uploader :binary, ProviderVersionUploader

  before_create -> { generate_id('provpltfrm') }
end
