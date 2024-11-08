class ReconcileAwsNetworkJob
  include Sidekiq::Job

  def perform(*args)
    @network = AwsNetwork.find(args.first)
    # Anytime we create a network, first we check
    # for an existing VPC tagged with the aws-network
    # ID, to prevent creating multiple networks

    ec2 = Aws::EC2::Client.new(
      region: @network.region,
      credentials: credentials
    )

    if @network.vpc_id.blank?
      # Create the new network
      @vpc = ec2.create_vpc
    else
      # Update the existing network

    end

  end
end
