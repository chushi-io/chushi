class Api::V2::AwsNetworksController < ApplicationController
  def index

  end

  def show

  end

  def create

  end

  def update

  end

  def destroy

  end

  private
  def aws_network_params
    map_params(%i[
      name
      region
      cidr-block
      cloud-provider
    ])
  end
end
