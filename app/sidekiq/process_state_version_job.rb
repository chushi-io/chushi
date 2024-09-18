class ProcessStateVersionJob
  include Sidekiq::Job

  def perform(*args)
    @version = StateVersion.find(args.first)
    unless @version.json_state_file.attached?
      puts "State version has not been uploaded"
      return
    end
    if @version.resources_processed
      puts "State version already processed"
      return
    end

    @version.json_state_file.open do |tempfile|
      parsed_json = ActiveSupport::JSON.decode(File.read(tempfile))
      parsed_json["values"]["outputs"].each do |key, output|
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

    @version.update(resources_processed: true)
  end
end
