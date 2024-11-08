# frozen_string_literal: true

class VirtualNetwork < ApplicationRecord
  belongs_to :organization

  belongs_to :network_attachable, polymorphic: true, optional: true

  before_create -> { generate_id('vnet') }
end
