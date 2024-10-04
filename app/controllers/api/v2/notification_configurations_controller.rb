class Api::V2::NotificationConfigurationsController < Api::ApiController
  def index
    @workspace = Workspace.find_by(external_id: params[:id])
    authorize! @workspace, to: :list_notification_configurations?

    render json: ::NotificationConfigurationSerializer.new(
      @workspace.notification_configurations,
      {}
    ).serializable_hash
  end

  def show
    @notification_configuration = NotificationConfiguration.find_by(external_id: params[:id])
    unless @notification_configuration
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @notification_configuration
    render json: ::NotificationConfigurationSerializer.new(
      @notification_configuration,
      {}
    ).serializable_hash
  end

  def create
    @workspace = Workspace.find_by(external_id: params[:id])
    authorize! @workspace, to: :create_notification_configurations?

    @config = @workspace.notification_configurations.new(
      notification_configuration_params
    )
    if @config.save
      render json: ::NotificationConfigurationSerializer.new(
        @config,
        {}
      ).serializable_hash
    else
      render json: @config.errors.full_messages, status: :bad_request
    end
  end

  def update
    @config = NotificationConfiguration.find_by(external_id: params[:id])
    unless @config
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @config
    if @config.update(notification_configuration_params)
      render json: ::NotificationConfigurationSerializer.new(
        @config,
        {}
      ).serializable_hash
    else
      render json: @config.errors.full_messages, status: :bad_request
    end
  end

  def verify
    head :not_implemented
  end

  def destroy
    @config = NotificationConfiguration.find_by(external_id: params[:id])
    unless @config
      skip_verify_authorized!
      head :not_found and return
    end

    authorize! @config
    if @config.delete
      head :accepted
    else
      render json: @config.errors.full_messages, status: :bad_request
    end
  end

  private
  def notification_configuration_params
    map_params([
      :workspace,
      "destination-type",
      :enabled,
      :name,
      :token,
      :triggers,
      :url
               ])
  end
end