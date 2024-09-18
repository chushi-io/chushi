class SshKeySerializer < ApplicationSerializer
  set_type "ssh-keys"

  attribute :name
end
