class CreateAwsNetworks < ActiveRecord::Migration[7.1]
  def change
    create_table :aws_networks, id: :uuid do |t|
      t.string :external_id, index: { unique: true }
      t.references :cloud_provider, foreign_key: true, type: :uuid

      t.string :name
      t.string :region
      t.string :cidr_block

      t.timestamps
    end
  end
end

#   create-vpc
# [--cidr-block <value>]
# [--ipv6-pool <value>]
# [--ipv6-cidr-block <value>]
# [--ipv4-ipam-pool-id <value>]
# [--ipv4-netmask-length <value>]
# [--ipv6-ipam-pool-id <value>]
# [--ipv6-netmask-length <value>]
# [--ipv6-cidr-block-network-border-group <value>]
# [--tag-specifications <value>]
# [--dry-run | --no-dry-run]
# [--instance-tenancy <value>]
# [--amazon-provided-ipv6-cidr-block | --no-amazon-provided-ipv6-cidr-block]
# [--cli-input-json <value>]
# [--generate-cli-skeleton <value>]
# [--debug]
# [--endpoint-url <value>]
# [--no-verify-ssl]
# [--no-paginate]
# [--output <value>]
# [--query <value>]
# [--profile <value>]
# [--region <value>]
# [--version <value>]
# [--color <value>]
# [--no-sign-request]
# [--ca-bundle <value>]
# [--cli-read-timeout <value>]
# [--cli-connect-timeout <value>]
