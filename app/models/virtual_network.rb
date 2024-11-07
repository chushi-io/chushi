# frozen_string_literal: true

class VirtualNetwork < ApplicationRecord
  belongs_to :organization

  before_create -> { generate_id('vnet') }
end
