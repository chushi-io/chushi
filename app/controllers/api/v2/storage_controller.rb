class Api::V2::StorageController < Api::ApiController
  skip_before_action :verify_access_token
  skip_verify_authorized

  before_action :load_storage_object
  def show
    case @object['class']
    when 'StateVersion'
      read_state_version
    when 'Plan'
      read_plan_file
    when 'RegistryModuleVersion'
      read_module_version
    when 'ProviderVersionPlatform'
      read_provider_version
    else
      head :bad_request
    end
  end

  def update
    # Decode the upload object
    case @object['class']
    when 'ConfigurationVersion'
      upload_configuration_version
    when 'StateVersion'
      upload_state_version
    when 'Plan'
      upload_plan_files
    when 'RegistryModuleVersion'
      upload_module_version
    when 'ProviderVersionPlatform'
      upload_provider_version
    else
      head :bad_request
    end
  end

  protected

  def load_storage_object
    token = Base64.decode64(params[:key])
    object = Vault::Rails.decrypt('transit', 'chushi_storage_url', token)
    @object = JSON.parse object
  end

  def read_state_version
    @version = StateVersion.find(@object['id'])
    if @object['file'] == 'state'
      head :not_found and return unless @version.state_file.present?

      decrypt(@version.state_file)
    else
      head :not_found and return unless @version.state_json_file.present?

      decrypt(@version.state_json_file)
    end
  end

  def read_module_version
    @version = RegistryModuleVersion.find(@object['id'])
    response.headers['Content-Disposition'] = 'attachment; filename="archive.tar.gz"'
    response.headers['Content-Type'] = 'application/gzip'
    decrypt(@version.archive)
  end

  def read_provider_version
    @version = ProviderVersionPlatform.find(@object['id'])
    response.headers['Content-Disposition'] = "attachment; filename=\"#{@version.filename}\""
    response.headers['Content-Type'] = 'application/gzip'
    decrypt(@version.binary)
  end

  def upload_configuration_version
    @version = ConfigurationVersion.find(@object['id'])
    @version.archive = get_uploaded_file(@version.id)
    render json: @version.errors.full_messages unless @version.save!

    if @version.auto_queue_runs
      # TODO: Trigger a job for queueing the runs after upload
    end
    @version.status = 'uploaded'
    @version.save

    ConfigurationVersionUploadedJob.perform_async(@version.id)
    head :created
  end

  def upload_state_version
    @version = StateVersion.find(@object['id'])
    file = get_uploaded_file(@object['id'])
    case @object['file']
    when 'state'
      @version.state_file = file
      @version.save!
      @version.workspace.update!(current_state_version_id: @version.id)
      ProcessStateVersionJob.perform_async(@version.id)
      head :created
    when 'state.json'
      @version.state_json_file = file
      @version.save!
    else
      head :bad_request
    end
  end

  def upload_module_version
    @version = RegistryModuleVersion.find(@object['id'])
    @version.archive = get_uploaded_file(@object['id'])
    @version.save!
    head :created
  end

  def upload_provider_version
    @version = ProviderVersionPlatform.find(@object['id'])
    @version.binary = get_uploaded_file(@object['id'])
    @version.save!
    head :created
  end

  # Handle structured json, binary plan, json plan, and logs
  def upload_plan_files
    @plan = Plan.find(@object['id'])
    file = get_uploaded_file(@object['id'])
    case @object['file']
    when 'tfplan.json'
      @plan.plan_json_file = file
    when 'structured.json'
      @plan.plan_structured_file = file
    when 'tfplan'
      @plan.plan_file = file
    when 'logs'
      @plan.logs = file
    else
      head :bad_request
    end
    @plan.save!
    head :created
  end

  def read_plan_file
    @plan = Plan.find(@object['id'])
    case @object['file']
    when 'tfplan.json'
      read_tfplan_json
    when 'structured.json'
      read_structured_json
    when 'tfplan'
      read_tfplan
    when 'logs'
      read_logs
    else
      head :bad_request
    end
  end

  def read_tfplan_json
    head :not_found and return unless @plan.plan_json_file.present?

    decrypt(@plan.plan_json_file)
  end

  def read_structured_json
    head :not_found and return unless @plan.plan_structured_file.present?

    decrypt(@plan.plan_structured_file)
  end

  def read_tfplan
    head :not_found and return unless @plan.plan_file.present?

    decrypt(@plan.plan_file)
  end

  def read_logs
    head :not_found and return unless @plan.logs.present?

    decrypt(@plan.logs.url)
  end

  def get_uploaded_file(path)
    request.body.rewind
    tempfile = Tempfile.new(path)
    tempfile.binmode
    tempfile << Vault::Rails.encrypt('transit', 'chushi_storage_contents', request.body.read)
    tempfile.rewind

    tempfile
  end

  def decrypt(obj)
    contents = obj.read
    contents = Vault::Rails.decrypt('transit', 'chushi_storage_contents', obj.read) if contents.start_with?('vault:')
    render body: contents, layout: false
  end
end
