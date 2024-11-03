# frozen_string_literal: true

module Api
  module V2
    class StorageController < Api::ApiController
      skip_before_action :verify_access_token
      skip_before_action :set_default_response_format

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
        when 'Apply'
          read_apply_file
        else
          head :bad_request
        end
      end

      def update
        # Decode the upload object
        Rails.logger.debug @object.to_json
        case @object['class']
        when 'ConfigurationVersion'
          upload_configuration_version
        when 'StateVersion'
          upload_state_version
        when 'Plan'
          upload_plan_files
        when 'Apply'
          upload_apply_files
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
        if @object['filename'] == 'state'
          head :not_found and return if @version.state_file.blank?

          contents = decrypt(@version.state_file)
        else
          head :not_found and return if @version.state_json_file.blank?

          contents = decrypt(@version.state_json_file)
        end
        render body: contents, layout: false
      end

      def read_module_version
        @version = RegistryModuleVersion.find(@object['id'])
        response.headers['Content-Disposition'] = 'attachment; filename="archive.tar.gz"'
        response.headers['Content-Type'] = 'application/gzip'
        contents = decrypt(@version.archive)
        render body: contents, layout: false
      end

      def read_provider_version
        @version = ProviderVersionPlatform.find(@object['id'])
        response.headers['Content-Disposition'] = "attachment; filename=\"#{@version.filename}\""
        response.headers['Content-Type'] = 'application/gzip'
        contents = decrypt(@version.binary)
        render body: contents, layout: false
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
        case @object['filename']
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
        case @object['filename']
        when 'tfplan.json'
          @plan.plan_json_file = file
        when 'structured.json'
          @plan.plan_structured_file = file
        when 'tfplan'
          @plan.plan_file = file
        when 'logs'
          @plan.logs = file
        when 'redacted.json'
          @plan.redacted_json = file
        else
          head :bad_request and return
        end
        @plan.save!

        ProcessPlanJob.perform_async(@plan.id) if @object['filename'] == 'redacted.json'
        head :created
      end

      def upload_apply_files
        @apply = Apply.find(@object['id'])
        file = get_uploaded_file(@object['id'])
        case @object['filename']
        when 'logs'
          @apply.logs = file
        else
          head :bad_request and return
        end
        @apply.save!
      end

      def read_plan_file
        @plan = Plan.find(@object['id'])
        case @object['filename']
        when 'tfplan.json'
          read_tfplan_json
        when 'structured.json'
          read_structured_json
        when 'tfplan'
          read_tfplan
        when 'logs'
          read_logs(@plan.logs)
        when 'redacted.json'
          read_redacted_json
        else
          head :bad_request
        end
      end

      def read_apply_file
        @apply = Apply.find(@object['id'])

        case @object['filename']
        when 'logs'
          read_logs(@apply.logs)
        else
          head :bad_request
        end
      end

      def read_tfplan_json
        head :not_found and return if @plan.plan_json_file.blank?

        contents = decrypt(@plan.plan_json_file)
        render body: contents, layout: false
      end

      def read_structured_json
        head :not_found and return if @plan.plan_structured_file.blank?

        contents = decrypt(@plan.plan_structured_file)
        render body: contents, layout: false
      end

      def read_redacted_json
        head :not_found and return if @plan.redacted_json.blank?

        contents = decrypt(@plan.redacted_json)
        render body: contents, layout: false
      end

      def read_tfplan
        head :not_found and return if @plan.plan_file.blank?

        contents = decrypt(@plan.plan_file)
        render body: contents, layout: false
      end

      def read_logs(obj)
        head :no_content and return if obj.blank?

        contents = decrypt(obj)
        if params[:limit] && params[:offset]
          start = params[:offset].to_i
          end_index = params[:offset].to_i + params[:limit].to_i
          render body: contents[start..end_index], layout: false
        else
          render body: contents, layout: false
        end
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
        if contents.start_with?('vault:')
          contents = Vault::Rails.decrypt('transit', 'chushi_storage_contents',
                                          obj.read)
        end
        contents
      end
    end
  end
end
