# frozen_string_literal: true

class SshKeySerializer < ApplicationSerializer
  set_type 'ssh-keys'

  attribute :name
end
