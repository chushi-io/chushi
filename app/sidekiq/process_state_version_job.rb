class ProcessStateVersionJob
  include Sidekiq::Job

  def perform(*args)
    @version = StateVersion.find(args.first)
    unless @version.json_state_file.attached?
      puts "State version has not been uploaded"
      raise ActiveRecord::RecordNotFound
    end
    if @version.resources_processed
      puts "State version already processed"
      return
    end

    @version.json_state_file.open do |tempfile|
      # Parse all of the outputs
      @parsed_json = ActiveSupport::JSON.decode(File.read(tempfile))
      if @parsed_json["values"].has_key?("outputs")
        @parsed_json["values"]["outputs"].each do |key, output|
          @output = @version.state_version_outputs.find_by(name: key)
          if @output
            # We need to also update state versions?
          else
            output_type = output["type"]
            if output_type.kind_of?(Array)
              output_type = output["type"].to_json
            end

            value = output["value"].to_json
            if %w[string number].include?(output_type)
              value = output["value"]
            end
            @output = @version.state_version_outputs.create(
              sensitive: output["sensitive"],
              name: key,
              output_type: output_type,
              value: value
            )
          end
        end
      end

      # Parse resources / modules
      @modules = {
        :root => Hash.new(0)
      }
      @providers = {}
      @resources = []

      process_module(@parsed_json["values"]["root_module"], "root")
    end

    @version.update(
      resources_processed: true,
      modules: @modules,
      providers: @providers,
      resources: @resources,
    )
  end

  protected

  def process_module(contents, path)
    if contents.has_key?("resources")
      contents["resources"].each do |resource|
        resource_name = resource["name"]
        resource_type = resource["type"]
        provider_key = "provider[\"#{resource["provider_name"]}\"]"

        unless @modules.has_key?(path)
          @modules[path] = Hash.new(0)
        end
        @modules[path][resource_type] += 1
        unless @providers.has_key?(provider_key)
          @providers[provider_key] = Hash.new(0)
        end
        @providers[provider_key][resource_type] += 1
        # TODO: This is probably wildly inefficient
        found = false
        @resources.each do |obj|
          if obj["name"] == resource_name && obj["type"] == resource_type && obj["module"] == path && obj["provider"] == provider_key
            obj.count += 1
            found = true
            break
          end
        end
        unless found
          @resources.append({
                              name: resource_name,
                              type: resource_type,
                              count: 1,
                              module: path,
                              provider: provider_key
                            })
        end
      end
    end

    if contents.has_key?("child_modules")
      contents["child_modules"].each do |child|
        process_module(child, "root.#{child["address"].split(".").delete_if {|x| x == "module"}.join(".")}")
      end
    end
  end

end
