Rails.application.routes.draw do
  devise_for :users

  get '.well-known/terraform.json', :controller => :well_known, :action => :terraform

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
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      post :webhooks, action: :create, :controller => "webhooks"
      get :ping, action: :ping, :controller => "ping"
      scope "/organizations/:organization_id", as: :organization do
        get "entitlement-set", action: :entitlements, :controller => "organizations"
        get "workspaces", action: :index, :controller => "workspaces"
        get "workspaces/:id", action: :show, :controller => "workspaces"
        get "runs/queue", action: :queue, :controller => "organizations"
        match "tags", via: [:get, :post, :delete], :controller => "organizations"
      end

      get "state-versions/:id", action: :get_state_version, :controller => "workspaces"
      match "state-versions/:id/state", via: [:get, :put], action: :state_version_state, :controller => "workspaces", :as => :state_version_state
      match "state-versions/:id/state-json", via: [:get, :put], action: :state_version_state_json, :controller => "workspaces", :as => :state_version_state_json

      resources :workspaces, :except => [:index] do
        member do
          post "actions/lock", action: :lock, :controller => "workspaces"
          post "actions/unlock", action: :unlock, :controller => "workspaces"
          post "actions/force-unlock", action: :force_unlock, :controller => "workspaces"
          match "state-versions", via: [:get, :post], action: :state_versions, :controller => "workspaces"

          get "current-state-version", action: :current_state_version, :controller => "workspaces"
          match "relationships/tags", via: [:get, :post, :delete], action: :tags, :controller => :workspaces
          get :runs
          post :configuration_versions, action: :create, :controller => "configuration_versions", path: "configuration-versions"
        end
      end

      resources :plans do
        member do
          match "logs", via: [:get, :post], :controller => "plans"
          get "logs", action: :logs, :controller => "plans"
          post "upload"
          post "upload_json"
          post "upload_structured"
          post "download"
          get "json-output-redacted", action: :json_output_redacted
        end
      end
      resources :applies do
        member do
          get "logs", action: :logs
        end
      end
      resources :runs, :except => [:index] do
        member do
          post "actions/discard", action: :discard, :controller => "runs"
          post "actions/cancel", action: :cancel, :controller => "runs"
          post "actions/force-cancel", action: :force_cancel, :controller => "runs"
          post "actions/force-execute", action: :force_execute, :controller => "runs"
          post "actions/apply", action: :apply, :controller => :runs
          get "configuration-version/download", action: :download, :controller => "configuration_versions", param: :run_id
          get "run-events", action: :events, :controller => :runs
        end
      end
      resources :agents
      resources :configuration_versions, :except => [:create], path: "configuration-versions" do
        member do
          put "upload", action: :upload, :controller => "configuration_versions"
          get "download", action: :download, :controller => "configuration_versions"
        end
      end
    end

  end

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
