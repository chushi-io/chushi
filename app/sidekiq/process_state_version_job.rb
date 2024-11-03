# frozen_string_literal: true

class ProcessStateVersionJob
  include Sidekiq::Job

  def perform(*args)
    @version = StateVersion.find(args.first)
    unless @version.state_json_file.attached?
      Rails.logger.debug 'State version has not been uploaded'
      raise ActiveRecord::RecordNotFound
    end
    if @version.resources_processed
      Rails.logger.debug 'State version already processed'
      return
    end

    @parsed_json = ActiveSupport::JSON.decode(
      Vault::Rails.decrypt('transit', 'chushi_storage_contents', @version.state_json_file.read)
    )
    if @parsed_json['values'].key?('outputs')
      @parsed_json['values']['outputs'].each do |key, output|
        @output = @version.state_version_outputs.find_by(name: key)
        if @output
          # We need to also update state versions?
        else
          output_type = output['type']
          output_type = output['type'].to_json if output_type.is_a?(Array)

          value = output['value'].to_json
          value = output['value'] if %w[string number].include?(output_type)
          @output = @version.state_version_outputs.create(
            sensitive: output['sensitive'],
            name: key,
            output_type:,
            value:
          )
        end
      end
    end

    # Parse resources / modules
    @modules = {
      root: Hash.new(0)
    }
    @providers = {}
    @resources = []

    process_module(@parsed_json['values']['root_module'], 'root')

    @version.update(
      resources_processed: true,
      modules: @modules,
      providers: @providers,
      resources: @resources
    )
  end

  protected

  def process_module(contents, path)
    if contents.key?('resources')
      contents['resources'].each do |resource|
        resource_name = resource['name']
        resource_type = resource['type']
        provider_key = "provider[\"#{resource['provider_name']}\"]"

        @modules[path] = Hash.new(0) unless @modules.key?(path)
        @modules[path][resource_type] += 1
        @providers[provider_key] = Hash.new(0) unless @providers.key?(provider_key)
        @providers[provider_key][resource_type] += 1
        # TODO: This is probably wildly inefficient
        found = false
        @resources.each do |obj|
          next unless obj[:name] == resource_name && obj[:type] == resource_type && obj[:module] == path && obj[:provider] == provider_key

          obj[:count] += 1
          found = true
          break
        end
        next if found

        @resources.append({
                            name: resource_name,
                            type: resource_type,
                            count: 1,
                            module: path,
                            provider: provider_key
                          })
      end
    end

    return unless contents.key?('child_modules')

    contents['child_modules'].each do |child|
      process_module(child, "root.#{child['address'].split('.').delete_if { |x| x == 'module' }.join('.')}")
    end
  end
end
