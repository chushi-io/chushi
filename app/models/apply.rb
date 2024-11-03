# frozen_string_literal: true

class Apply < ApplicationRecord
  has_one :run
  has_many :state_versions

  mount_uploader :logs, ApplyLogUploader

  before_create -> { generate_id('apply') }
end
