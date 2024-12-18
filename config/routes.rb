# frozen_string_literal: true

Rails.application.routes.draw do
  # Authentication / Authorizat
  use_doorkeeper
  use_doorkeeper_openid_connect
  devise_for :users
  get '.well-known/app.json', controller: :well_known, action: :app
  get '.well-known/terraform.json', controller: :well_known, action: :terraform
  get 'github/setup', controller: :github, action: :setup

  get 'app/*_', controller: :application, action: :index

  # Registry Routes
  namespace :registry, defaults: { format: :json } do
    namespace :v1 do
      scope 'modules', controller: 'modules' do
        get '/', action: :index
        get '/:namespace', action: :index
        get '/search', action: :search
        get '/:namespace/:name/:provider/versions', action: :versions
        get '/:namespace/:name/:provider/:version/download', action: :download, constraints: { version: %r{[^/]+} }
        get '/archive/:namespace/:name/:provider/:version/*.tar.gz', action: :archive, as: :archive,
                                                                     constraints: { version: %r{[^/]+} }
        get '/:namespace/:name/:provider/download', action: :download
        get '/:namespace/:name', action: :latest
        get '/:namespace/:name/:provider', action: :latest
        get '/:namespace/:name/:provider/:version', action: :show, constraints: { version: %r{[^/]+} }
        post '/:namespace/:name/:provider/:version', action: :create, constraints: { version: %r{[^/]+} }
      end
      scope 'providers', controller: 'providers' do
        post '/:namespace/:type/:version', action: :create, constraints: { version: %r{[^/]+} }
        get '/:namespace/:type/versions', action: :index
      end
    end
  end

  # API Routes
  namespace :api, defaults: { format: :json } do
    namespace :v2 do
      post :webhooks, action: :create, controller: 'webhooks'
      get :ping, action: :ping, controller: 'ping'
      get 'account/details', action: :show, controller: :account_details
      get 'organizations', action: :index, controller: :organizations
      get 'object/:key', action: :show, controller: :storage, as: :get_storage
      put 'object/:key', action: :update, controller: :storage, as: :upload_storage
      post 'organizations', action: :create, controller: :organizations
      scope '/organizations/:organization_id', as: :organization do
        get '', action: :show, controller: :organizations
        patch '', action: :update, controller: :organizations
        get 'entitlement-set', action: :entitlements, controller: :organizations
        get 'workspaces', action: :index, controller: :workspaces
        get 'workspaces/:id', action: :show, controller: :workspaces
        get 'runs/queue', action: :queue, controller: :organizations
        match 'tags', via: %i[get post delete], controller: :organizations

        get 'agent-pools', action: :index, controller: 'agents'
        post 'agent-pools', action: :create, controller: 'agents'

        get 'cloud-providers', action: :index, controller: :cloud_providers
        post 'cloud-providers', action: :create, controller: :cloud_providers

        get 'tasks', action: :index, controller: 'run_tasks'
        post 'tasks', action: :create, controller: 'run_tasks'

        get 'projects', action: :index, controller: :projects
        post 'projects', action: :create, controller: :projects

        get 'teams', action: :index, controller: :teams
        post 'teams', action: :create, controller: :teams

        get 'varsets', action: :index, controller: :variable_sets
        post 'varsets', action: :create, controller: :variable_sets

        get 'policies', action: :index, controller: :policies
        post 'policies', action: :create, controller: :policies

        post 'organization-memberships', action: :create, controller: :organization_memberships
        get 'organization-memberships', action: :index, controller: :organization_memberships

        post 'oauth-clients', action: :create, controller: :oauth_clients
        get 'oauth-clients', action: :index, controller: :oauth_clients

        post :workspaces, action: :create, controller: :workspaces

        get 'ssh-keys', action: :index, controller: :ssh_keys
        post 'ssh-keys', action: :create, controller: :ssh_keys

        get 'team-tokens', action: :list_team_tokens, controller: :authentication_tokens
        post 'authentication-token', action: :create_organization_token, controller: :authentication_tokens
        get 'authentication-token', action: :get_organization_token, controller: :authentication_tokens

        # Routes for registry modules
        get 'registry-modules', action: :index, controller: :modules
        post 'registry-modules', action: :create, controller: :modules
        get 'registry-modules/private/:namespace/:name/:provider', action: :show, controller: :modules, as: :show_module
        patch 'registry-modules/private/:namespace/:name/:provider', action: :update, controller: :modules
        post 'registry-modules/private/:namespace/:name/:provider/versions', action: :create,
                                                                             controller: :module_versions, as: :module_versions
        delete 'registry-modules/private/:namespace/:name', action: :destroy, controller: :modules
        delete 'registry-modules/private/:namespace/:name/:provider', action: :destroy,
                                                                      controller: :modules
        delete 'registry-modules/private/:namespace/:name/:provider/:version', action: :destroy,
                                                                               controller: :module_versions
        # Routes for registry providers
        get 'registry-providers', action: :index, controller: :providers
        post 'registry-providers', action: :create, controller: :providers
        get 'registry-providers/private/:namespace/:name', action: :show, controller: :providers
        delete 'registry-providers/:registry_name/:namespace/:name', action: :destroy,
                                                                     controller: :providers
        get 'registry-providers/private/:namespace/:name/versions/', action: :index,
                                                                     controller: :provider_versions, as: :provider_versions
        post 'registry-providers/private/:namespace/:name/versions', action: :create,
                                                                     controller: :provider_versions
        get 'registry-providers/private/:namespace/:name/versions/:version', action: :show,
                                                                             controller: :provider_versions, as: :provider_version
        delete 'registry-providers/private/:namespace/:name/versions/:provider_version', action: :destroy,
                                                                                         controller: :provider_versions
        post 'registry-providers/private/:namespace/:name/versions/:version/platforms', action: :create,
                                                                                        controller: :provider_version_platforms, constraints: { version: %r{[^/]+} }
        get 'registry-providers/private/:namespace/:name/versions/:version/platforms', action: :index,
                                                                                       controller: :provider_version_platforms, constraints: { version: %r{[^/]+} }, as: :provider_version_platforms
        get 'registry-providers/private/:namespace/:name/versions/:version/platforms/:os/:arch', action: :show,
                                                                                                 controller: :provider_version_platforms, constraints: { version: %r{[^/]+} }
        delete 'registry-providers/private/:namespace/:name/versions/:version/platforms/:os/:arch', action: :destroy,
                                                                                                    controller: :provider_version_platforms, constraints: { version: %r{[^/]+} }
      end
      get 'authentication-tokens/:token_id', action: :show, controller: :authentication_tokens
      delete 'authentication-tokens/:token_id', action: :destroy, controller: :authentication_tokens
      get 'state-versions/:id', action: :show, controller: :state_versions
      get 'state-version-outputs/:id', action: :show, controller: :state_version_outputs

      resources :workspaces, except: %i[index create] do
        member do
          post 'actions/lock', action: :lock, controller: :workspaces
          post 'actions/unlock', action: :unlock, controller: :workspaces
          post 'actions/force-unlock', action: :force_unlock, controller: :workspaces

          get 'state-versions', action: :index, controller: :state_versions
          post 'state-versions', action: :create, controller: :state_versions
          get 'current-state-version', action: :current, controller: :state_versions
          get 'current-state-version-outputs', action: :current_outputs, controller: :state_versions
          match 'relationships/tags', via: %i[get post delete], action: :tags, controller: :workspaces
          get :runs
          post :configuration_versions, action: :create, controller: :configuration_versions,
                                        path: 'configuration-versions'

          get :run_triggers, action: :index, path: 'run-triggers', controller: :run_triggers
          post :run_triggers, action: :create, path: 'run-triggers', controller: :run_triggers

          get :notification_configurations, action: :index, path: 'notification-configurations',
                                            controller: :notification_configurations
          post :notification_configurations, action: :create, path: 'notification-configurations',
                                             controller: :notification_configurations

          resources :tasks, controller: :workspace_tasks, param: :task_id
        end
      end

      scope 'workspaces/:workspace_id' do
        resources :vars, path: 'relationships/vars', controller: :variables, except: [:show]
      end

      resources :plans do
        member do
          get 'logs', action: :logs, controller: :plans
          post 'upload'
          post 'upload_json'
          post 'upload_structured'
          post 'download'
          get 'json-output-redacted', action: :json_output_redacted
          post 'logs', action: :upload_logs
        end
      end

      resources :vars, controller: :variables, except: [:show]
      resources :applies
      resources :runs, except: [:index] do
        member do
          post 'actions/discard', action: :discard, controller: :runs
          post 'actions/cancel', action: :cancel, controller: :runs
          post 'actions/force-cancel', action: :force_cancel, controller: :runs
          post 'actions/force-execute', action: :force_execute, controller: :runs
          post 'actions/apply', action: :apply, controller: :runs
          get 'configuration-version/download', action: :download, controller: :configuration_versions,
                                                param: :run_id
          get 'run-events', action: :events, controller: :runs
          get 'oidc-token', action: :token
          post 'authentication-token', action: :create_run_token, controller: :authentication_tokens
          get 'task-stages', action: :index, controller: :task_stages
        end
      end
      # resources :agents
      resources :agents, path: 'agent-pools', except: %i[index create] do
        member do
          get 'authentication-tokens', action: :get_agent_tokens, controller: :authentication_tokens
          post 'authentication-tokens', action: :create_agent_token, controller: :authentication_tokens
          get 'jobs', action: :index, controller: :jobs
        end
      end

      resources :oauth_clients, path: 'oauth-clients', except: %i[index create] do
        member do
          get 'oauth-tokens', action: :index, controller: :oauth_tokens
        end
      end

      resources :oauth_tokens, path: 'oauth-tokens', except: %i[index create]
      resources :cloud_providers, path: 'cloud-providers', except: %i[index create]
      resources :virtual_networks, path: 'virtual-networks', except: %i[index create]
      resources :policies, except: %i[index create] do
        member do
          put 'upload', action: :upload
          get 'download', action: :download
        end
      end
      resources :run_tasks, path: 'tasks', except: %i[index create]
      get 'task-stages/:task_stage_id', action: :show, controller: :task_stages
      post 'run-task/null', action: :null_stage, controller: :task_results
      patch 'task-results/:task_result_id/callback', action: :callback, controller: :task_results,
                                                     as: :task_result_callback
      resources :projects, except: %i[index create]
      resources :teams, except: %i[index create] do
        member do
          post 'relationships/users', action: :add_users
          delete 'relationships/users', action: :remove_users
          post 'relationships/organization-memberships', action: :add_org_memberships
          delete 'relationships/organization-memberships', action: :remove_org_memberships
          get 'authentication-token', action: :get_team_token, controller: :authentication_tokens
          post 'authentication-token', action: :create_team_token, controller: :authentication_tokens
          delete 'authentication-token', action: :destroy_team_token, controller: :authentication_tokens
        end
      end

      resources :team_projects, path: 'team-projects'

      resources :varsets, except: %i[index create], controller: :variable_sets do
        member do
          get 'relationships/vars', action: :list_variables
          post 'relationships/vars', action: :add_variable
          patch 'relationships/vars/:variable_id', action: :update_variable
          delete 'relationships/vars/:variable_id', action: :delete_variable

          post 'relationships/workspaces', action: :add_workspaces
          delete 'relationships/workspaces', action: :delete_workspaces

          post 'relationships/projects', action: :add_projects
          delete 'relationships/projects', action: :delete_projects
        end
      end

      resources :configuration_versions, except: [:create], path: 'configuration-versions' do
        member do
          # put "upload", action: :upload, :controller => :configuration_versions
          get 'download', action: :download, controller: :configuration_versions
        end
      end

      resources :organization_memberships, except: %i[create index], path: 'organization-memberships'
      resources :notification_configurations, except: %i[create index], path: 'notification-configurations' do
        member do
          post 'verify', action: :verify, controller: :notification_configurations
        end
      end
      resources :run_triggers, except: %i[create index update], path: 'run-triggers'
      resources :ssh_keys, except: %i[create index], path: 'ssh-keys'
      resources :workspace_teams, path: 'team-workspaces'
      resources :jobs, except: %i[create index] do
        member do
          post :lock
          post :unlock
        end
      end
    end
  end

  # Agents routes
  namespace :agents, defaults: { format: :json } do
    namespace :v1 do
      put 'runs/:id', action: :update, controller: :runs
      get 'runs/:id/token', action: :token, controller: :runs

      put 'plans/:id', action: :update, controller: :plans
      put 'applies/:id', action: :update, controller: :applies
      put 'runs/:id/logs', action: :create, controller: :logs
    end
  end
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root to: redirect('/app/organizations')
end
