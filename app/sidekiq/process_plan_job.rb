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

    has_changes = false

    additions = 0
    changes = 0
    destructions = 0
    imports = 0

    # 	ActionNoop Action = "no-op"
    #
    # 	// ActionCreate denotes a create operation.
    # 	ActionCreate Action = "create"
    #
    # 	// ActionRead denotes a read operation.
    # 	ActionRead Action = "read"
    #
    # 	// ActionUpdate denotes an update operation.
    # 	ActionUpdate Action = "update"
    #
    # 	// ActionDelete denotes a delete operation.
    # 	ActionDelete Action = "delete"
    @parsed_json['resource_changes'].each do |change|
      actions = change['change']['actions']
      # Not accounted for here is "no-op"?
      if actions.include?('create')
        additions += 1
        has_changes = true
      elsif actions.include?('update')
        changes += 1
        has_changes = true
      elsif actions.include?('delete')
        destructions += 1
        has_changes = true
      elsif actions.include?('no-op')
        # For now, its a no-op :shrug:
      end

      if change['change']['importing']
        has_changes = true
        imports += 1
      end
    end

    unless has_changes
      @plan.update(has_changes: false)
      @plan.run.update(has_changes: false, status: 'planned_and_finished')
      return
    end

    update_attrs = {
      has_changes: true,
      resource_additions: additions,
      resource_changes: changes,
      resource_destructions: destructions,
      resource_imports: imports
    }

    @plan.update(update_attrs)
    @plan.run.update(
      has_changes: true,
      status: "planned_and_saved"
    )
  end
end
