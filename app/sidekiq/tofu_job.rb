# frozen_string_literal: true

class TofuJob
  include Sidekiq::Job

  def perform(*args)
    # Get our run information
    @run = Run.find(args.first)

    # Install terraform
    @tofu_version = @run.workspace.tofu_version
    @tofu_version = '1.8.2' if @tofu_version.blank?

    url = "https://github.com/opentofu/opentofu/releases/download/v#{@tofu_version}/tofu_#{@tofu_version}_darwin_arm64.zip"
    input = HTTParty.get(url).body
    Zip::File.open(StringIO.new(input)) do |io|
      while (entry = io.get_next_entry)
        Rails.logger.debug entry.name
      end
    end
    # Download the configuration version

    # Do some other stuff

    # Let's run some tofu

    # Do something
  end
end
