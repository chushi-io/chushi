# frozen_string_literal: true

class RunTrigger < ApplicationRecord
  belongs_to :workspace
  belongs_to :sourceable, class_name: 'Workspace'

  before_create -> { generate_id('rt') }
end
