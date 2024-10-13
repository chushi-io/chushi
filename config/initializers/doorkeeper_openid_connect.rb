# frozen_string_literal: true

Doorkeeper::OpenidConnect.configure do
  issuer Chushi.domain

  signing_key do
    if ENV.has_key?('OIDC_PRIVATE_KEY')
      ENV.fetch('OIDC_PRIVATE_KEY')
    else
      File.read(ENV.fetch('OIDC_PRIVATE_KEY_FILE', 'oidc_key.pem'))
    end
  end

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    Run.find_by(id: access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    # Example implementation:
    # resource_owner.current_sign_in_at
  end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # sign_out resource_owner
    # redirect_to new_user_session_url
  end

  # Depending on your configuration, a DoubleRenderError could be raised
  # if render/redirect_to is called at some point before this callback is executed.
  # To avoid the DoubleRenderError, you could add these two lines at the beginning
  #  of this callback: (Reference: https://github.com/rails/rails/issues/25106)
  #   self.response_body = nil
  #   @_response_body = nil
  select_account_for_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # redirect_to account_select_url
  end

  subject do |resource_owner, _application|
    organization = resource_owner.workspace.organization.name
    project = 'default'
    project = resource_owner.workspace.project.external_id unless resource_owner.workspace.project.nil?
    workspace = resource_owner.workspace.name
    operation = 'plan'
    "organization:#{organization}:project:#{project}:workspace:#{workspace}:run_phase:#{operation}"
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  protocol do
    :https
  end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  expiration 3600

  # Example claims:
  claims do
    claim :workspace, response: %i[id_token user_info] do |resource_owner|
      resource_owner.id
    end

    claim :project, response: %i[id_token user_info] do |resource_owner|
      resource_owner.agent_id
    end

    claim :organization, response: %i[id_token user_info] do |resource_owner|
      resource_owner.organization_id
    end

    #   normal_claim :_foo_ do |resource_owner|
    #     resource_owner.foo
    #   end

    #   normal_claim :_bar_ do |resource_owner|
    #     resource_owner.bar
    #   end
  end
end
