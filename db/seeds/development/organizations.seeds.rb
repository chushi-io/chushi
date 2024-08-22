# Create the default Chushi organization
Organization
  .create_with(
    organization_type: 'business',
    allow_auto_create_workspace: true
  ).find_or_create_by(name: 'chushi')