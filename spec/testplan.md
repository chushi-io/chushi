# Manual integration tests

Pending the creation of automated integration tests, the 
following manual steps are performed after deployment to verify functionality 

## Setup 
``` 
export TF_CLOUD_ORGANIZATION=chushi
export TF_CLOUD_HOSTNAME=cloud.chushi.io
```

You'll also need a token with the appropriate permissions in 
your `~/.terraform.d/credentials.tfrc.json`

## Workspaces 

**TODO**: These should all be generated using a script to 
create and configure the workspaces

Local: `chushi-infra-workspace-testing`

Remote: `chushi-infra-workspace-testing-remote`

Agent: `chushi-infra-workspace-testing-agent`

Tags: `chushi-infra-workspace-testing-tags`

### Creation

```ruby 
@organization = Organization.find_by(name: 'chushi')
@agent_pool = @organization.agent_pools.create(name: 'testing-agent')
@organization.workspaces.create(name: 'chushi-infra-workspace-testing', execution_mode: 'local')
@organization.workspaces.create(name: 'chushi-infra-workspace-testing-remote', execution_mode: 'remote')
@organization.workspaces.create(name: 'chushi-infra-workspace-testing-agent', execution_mode: 'agent', agent_pool_id: @agent_pool.id)
```

### Execution
For each workspace:
```shell 
cd /path/to/workspace 
tofu init 
tofu plan 
tofu apply # approve 
tofu plan # verify no changes after plan
```