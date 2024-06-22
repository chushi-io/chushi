class PoliciesController < AuthenticatedController
  def index
    @policies = @organization.policies
  end

  def new
    @policy = @organization.policies.build
  end
end
