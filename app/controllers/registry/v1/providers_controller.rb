# frozen_string_literal: true

module Registry
  module V1
    class ProvidersController < Registry::RegistryController
      def index; end

      def create
        @provider = Provider.new(
          namespace: params[:namespace],
          provider_type: params[:type],
          version: params[:version]
        )
        @provider.published_at = Time.zone.now
        @provider.save!
        request.body.rewind
        @provider.archive.attach(io: request.body,
                                 filename: "#{params[:namespace]}-#{params[:name]}-#{params[:provider]}-#{params[:version]}.tar.gz")
        render json: @provider
      end
    end
  end
end
