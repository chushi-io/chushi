Rails.application.routes.draw do

  # Authentication / Authorizat
  use_doorkeeper
  use_doorkeeper_openid_connect
  devise_for :users
  get '.well-known/terraform.json', :controller => :well_known, :action => :terraform
  get 'github/setup', :controller => :github, :action => :setup

  # Application Routing
  resources :workspaces do
    resources :runs
  end

  resources :state_versions
  resources :applies
  resources :plans
  resources :runs
  resources :agents
  resources :configuration_versions
  resources :variables
  resources :variable_sets
  resources :vcs_connections
  resources :policies
  resources :policy_sets
  resources :organizations do
    resources :access_tokens, :controller => "organization_tokens", as: :access_tokens
  end

  resources :access_tokens, :controller => "user_tokens", as: :access_tokens

  # Registry Routes
  namespace :registry, defaults: {format: :json} do
    namespace :v1 do
      scope "modules", :controller => "modules" do
        get "/", action: :index
        get "/:namespace", action: :index
        get "/search", action: :search
        get "/:namespace/:name/:provider/versions", action: :versions
        get "/:namespace/:name/:provider/:version/download", action: :download, constraints: { version: /[^\/]+/ }
        get "/archive/:namespace/:name/:provider/:version/*.tar.gz", action: :archive, as: :archive, constraints: { version: /[^\/]+/ }
        get "/:namespace/:name/:provider/download", action: :download
        get "/:namespace/:name", action: :latest
        get "/:namespace/:name/:provider", action: :latest
        get "/:namespace/:name/:provider/:version", action: :show, constraints: { version: /[^\/]+/ }
        post "/:namespace/:name/:provider/:version", action: :create, constraints: { version: /[^\/]+/ }
      end
      scope "providers", :controller => "providers" do
        post "/:namespace/:type/:version", action: :create, constraints: { version: /[^\/]+/ }
        get "/:namespace/:type/versions", action: :index
      end
    end
  end

  match "org_selector" => "organizations#selector", as: :organization_selector, via: [:get, :post]

  # API Routes
  namespace :api, defaults: {format: :json} do
    namespace :v2 do
      post :webhooks, action: :create, :controller => "webhooks"
      get :ping, action: :ping, :controller => "ping"
      scope "/organizations/:organization_id", as: :organization do
        get "", action: :show, :controller => "organizations"
        patch "", action: :update, :controller => "organizations"
        get "entitlement-set", action: :entitlements, :controller => "organizations"
        get "workspaces", action: :index, :controller => "workspaces"
        get "workspaces/:id", action: :show, :controller => "workspaces"
        get "runs/queue", action: :queue, :controller => "organizations"
        match "tags", via: [:get, :post, :delete], :controller => "organizations"

        get "agent-pools", action: :index, :controller => "agents"
        post "agent-pools", action: :create, :controller => "agents"

        get "tasks", action: :index, :controller => "run_tasks"
        post "tasks", action: :create, :controller => "run_tasks"

        get "projects", action: :index, :controller => :projects
        post "projects", action: :create, :controller => :projects

        get "teams", action: :index, :controller => :teams
        post "teams", action: :create, :controller => :teams

        get "varsets", action: :index, :controller => :variable_sets
        post "varsets", action: :create, :controller => :variable_sets

        post "organization-memberships", action: :create, :controller => :organization_memberships
        get "organization-memberships", action: :index, :controller => :organization_memberships

        post :workspaces, action: :create, :controller => :workspaces

        get "ssh-keys", action: :index, :controller => :ssh_keys
        post "ssh-keys", action: :create, :controller => :ssh_keys

        get "team-tokens", action: :list_team_tokens, :controller => :authentication_tokens
        post "authentication-token", action: :create_organization_token, :controller => :authentication_tokens
        get "authentication-token", action: :get_organization_token, :controller => :authentication_tokens
      end
      get "authentication-tokens/:token_id", action: :show, :controller => :authentication_tokens
      delete "authentication-tokens/:token_id", action: :destroy, :controller => :authentication_tokens
      get "state-versions/:id", action: :show, :controller => :state_versions
      get "state-versions/:id/state", action: :state, :controller => :state_versions, as: :get_state
      put "state-versions/:id/state", action: :upload_state, :controller => :state_versions, as: :upload_state
      get "state-versions/:id/state-json", action: :state_json, :controller => :state_versions, as: :get_state_json
      put "state-versions/:id/state-json", action: :upload_state_json, :controller => :state_versions, as: :upload_state_json
      get "state-version-outputs/:id", action: :show, :controller => :state_version_outputs

      resources :workspaces, :except => [:index, :create] do
        member do
          post "actions/lock", action: :lock, :controller => :workspaces
          post "actions/unlock", action: :unlock, :controller => :workspaces
          post "actions/force-unlock", action: :force_unlock, :controller => :workspaces


          get "state-versions", action: :index, :controller => :state_versions
          post "state-versions", action: :create, :controller => :state_versions
          get "current-state-version", action: :current, :controller => :state_versions
          get "current-state-version-outputs", action: :current_outputs, :controller => :state_versions
          match "relationships/tags", via: [:get, :post, :delete], action: :tags, :controller => :workspaces
          get :runs
          post :configuration_versions, action: :create, :controller => :configuration_versions, path: "configuration-versions"

          get :run_triggers, action: :index, path: "run-triggers", :controller => :run_triggers
          post :run_triggers, action: :create, path: "run-triggers", :controller => :run_triggers
        end
      end

      scope "workspaces/:workspace_id" do
        resources :vars, path: "relationships/vars", :controller => :variables, :except => [:show]
      end

      resources :plans do
        member do
          match "logs", via: [:get, :post], :controller => :plans
          get "logs", action: :logs, :controller => :plans
          post "upload"
          post "upload_json"
          post "upload_structured"
          post "download"
          get "json-output-redacted", action: :json_output_redacted
        end
      end

      resources :vars, :controller => :variables, :except => [:show]
      resources :applies do
        member do
          get "logs", action: :logs
        end
      end
      resources :runs, :except => [:index] do
        member do
          post "actions/discard", action: :discard, :controller => :runs
          post "actions/cancel", action: :cancel, :controller => :runs
          post "actions/force-cancel", action: :force_cancel, :controller => :runs
          post "actions/force-execute", action: :force_execute, :controller => :runs
          post "actions/apply", action: :apply, :controller => :runs
          get "configuration-version/download", action: :download, :controller => :configuration_versions, param: :run_id
          get "run-events", action: :events, :controller => :runs
        end
      end
      # resources :agents
      resources :agents, path: "agent-pools", :except => [:index, :create] do
        member do
          get "authentication-token", action: :get_agent_token, :controller => :authentication_tokens
          post "authentication-token", action: :create_agent_token, :controller => :authentication_tokens
        end
      end
      resources :run_tasks, path: "tasks", :except => [:index, :create]
      resources :projects, :except => [:index, :create]
      resources :teams, :except => [:index, :create] do
        member do
          post "relationships/users", action: :add_users
          delete "relationships/users", action: :remove_users
          post "relationships/organization-memberships", action: :add_org_memberships
          delete "relationships/organization-memberships", action: :remove_org_memberships
          get "authentication-token", action: :get_team_token, :controller => :authentication_tokens
          post "authentication-token", action: :create_team_token, :controller => :authentication_tokens
          delete "authentication-token", action: :destroy_team_token, :controller => :authentication_tokens
        end
      end

      resources :team_projects, path: "team-projects"

      resources :varsets, :except => [:index, :create], :controller => :variable_sets do
        member do
          get "relationships/vars", action: :list_variables
          post "relationships/vars", action: :add_variable
          patch "relationships/vars/:variable_id", action: :update_variable
          delete "relationships/vars/:variable_id", action: :delete_variable

          post "relationships/workspaces", action: :add_workspaces
          delete "relationships/workspaces", action: :delete_workspaces

          post "relationships/projects", action: :add_projects
          delete "relationships/projects", action: :delete_projects
        end
      end

      resources :configuration_versions, :except => [:create], path: "configuration-versions" do
        member do
          put "upload", action: :upload, :controller => :configuration_versions
          get "download", action: :download, :controller => :configuration_versions
        end
      end

      resources :organization_memberships, :except => [:create, :index], path: "organization-memberships"
      resources :run_triggers, :except => [:create, :index, :update], path: "run-triggers"
      resources :ssh_keys, :except => [:create, :index], path: "ssh-keys"
      resources :workspace_teams, path: "team-workspaces"
    end
  end

  # Agents routes
  namespace :agents, defaults: {format: :json} do
    namespace :v1 do
      put "runs/:id", action: :update, :controller => :runs
      get "runs/:id/token", action: :token, :controller => :runs

      put "plans/:id", action: :update, :controller => :plans
      put "applies/:id", action: :update, :controller => :applies
      put "runs/:id/logs", action: :create, :controller => :logs
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "workspaces#index"
end
