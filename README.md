# Chushi 

TODO: 
- State versions are created, but we need to support storing the actual file contents
- Better error handling and status management of workspace / run / plan / apply
- UX handling of locked workspace
- Streaming of logs for plan / apply operations
- Support for destroy, refresh, etc
- Implementation of Drift detection schedule
- Implementation of Auto Destroy


### Generating an OIDC token for agents / workspaces 
```ruby 
@workspace = Workspace.first
@access_token = Doorkeeper::AccessToken.create(resource_owner_id: @workspace.id)
@access_token.save! 
@id_token = Doorkeeper::OpenidConnect::IdToken.new(@access_token)
puts @id_token.as_jws_token
```

This token can then be stored in the filesystem, and used to authenticate to a CSP