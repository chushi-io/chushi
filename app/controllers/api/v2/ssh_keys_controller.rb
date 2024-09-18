class Api::V2::SshKeysController < Api::ApiController
  def index
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :list_ssh_keys?

    @ssh_keys = @org.ssh_keys
    render json: ::SshKeySerializer.new(@ssh_keys, {}).serializable_hash
  end

  def create
    @org = Organization.find_by(name: params[:organization_id])
    authorize! @org, to: :create_ssh_keys?

    @ssh_key = @org.ssh_keys.new(name: ssh_key_params["name"], private_key: ssh_key_params["value"])
    if @ssh_key.save
      render json: ::SshKeySerializer.new(@ssh_key, {}).serializable_hash
    else
      render json: @ssh_key.errors.full_messsages, status: :bad_request
    end
  end

  def show
    @ssh_key = SshKey.find_by(external_id: params[:id])
    unless @ssh_key
      skip_verify_authorized!
      head :not_found and return
    end
    authorize! @ssh_key
    render json: ::SshKeySerializer.new(@ssh_key, {}).serializable_hash
  end

  def update
    @ssh_key = SshKey.find_by(external_id: params[:id])
    authorize! @ssh_key
    if @ssh_key.update(name: ssh_key_params["name"])
      render json: ::SshKeySerializer.new(@ssh_key, {}).serializable_hash
    else
      render json: @ssh_key.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    @ssh_key = SshKey.find_by(external_id: params[:id])
    authorize! @ssh_key
    if @ssh_key.delete
      head :accepted
    else
      render json: @ssh_key.errors.full_messages, status: :bad_request
    end
  end

  private
  def ssh_key_params
    map_params([:name, :value])
  end
end
