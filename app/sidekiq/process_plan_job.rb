class ProcessPlanJob
  include Sidekiq::Job

  def perform(*args)
    # Do something
    @plan = Plan.find(args.first)

    # This should only ever be triggered after uploading a JSON file
    return unless @plan.redacted_json.present?

    @parsed_json = ActiveSupport::JSON.decode(
      Vault::Rails.decrypt('transit', 'chushi_storage_contents', @plan.redacted_json.read)
    )

    puts @parsed_json['resource_changes']
    if @parsed_json['resource_changes'].length == 0
      @plan.update(has_changes: false)
      @plan.run.update(has_changes: false, status: 'planned_and_finished')
      return
    end

    additions = 0
    changes = 0
    destructions = 0
    imports = 0

    @parsed_json['resource_changes'].each do |change|
      actions = change['change']['actions']
      puts actions
      if actions.include?('create')
        additions += 1
      elsif actions.incldue?('delete')
        changes += 1
      elsif actions.include?('')
        destructions += 1
      elsif actions.include?('')
        imports += 0
      end
    end

    update_attrs = {
      has_changes: true,
      resource_additions: additions,
      resource_changes: changes,
      resource_destructions: destructions,
      resource_imports: imports
    }

    puts update_attrs
    @plan.update(update_attrs)
    @plan.run.update(
      has_changes: true,
      status: "planned_and_saved"
    )
  end
end
