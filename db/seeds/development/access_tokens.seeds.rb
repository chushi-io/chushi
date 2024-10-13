# frozen_string_literal: true

after 'development:users' do
  # Generate an access token for the user
  User
    .find_by(email: 'tofu@tofuisgreat.com')
    .access_tokens
    .find_or_create_by(name: 'chushi-development-token')

  # Generate an access token for the organization
  Organization
    .find_by(name: 'chushi')
    .access_tokens
    .find_or_create_by(name: 'chushi-org-token')
end
