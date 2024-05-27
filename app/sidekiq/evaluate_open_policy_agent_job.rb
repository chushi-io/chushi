class EvaluateOpenPolicyAgentJob
  include Sidekiq::Job

  def perform(*args)
    # Do something
    # Download the generated terraform plan
    # Evaluate Open Policy Agent against the plan
    # Stash the details as required
  end
end
