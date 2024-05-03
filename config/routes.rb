Rails.application.routes.draw do
  devise_for :users

  get '.well-known/terraform.json', to: ->(env) {
    [200, {}, [{
      "modules.v1": "/api/v1/registry/modules/",
      "providers.v1": "/api/v1/registry/providers/",
      "motd.v1": "/api/tofu/motd",
      "state.v2": "/api/v1/",
      "tfe.v2": "/api/v1/",
      "tfe.v2.1": "/api/v1/",
      "tfe.v2.2": "/api/v1/",
      "versions.v1": "/api/v1/versions/"
    }.to_json]]
  }
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
        get "/:namespace/:name/:provider/:version/download", action: :download
        get "/:namespace/:name/:provider/download", action: :download
        get "/:namespace/:name", action: :latest
        get "/:namespace/:name/:provider", action: :latest
        get "/:namespace/:name/:provider/:version", action: :show
        post "/:namespace/:name/:provider/:version", action: :create
      end
      scope "providers", :controller => "providers" do
        post "/:namespace/:type/:version", action: :create
        get "/:namespace/:type/versions", action: :index
      end
    end
  end

  match "org_selector" => "organizations#selector", as: :organization_selector, via: [:get, :post]
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      get :ping, action: :ping, :controller => "ping"
      scope "/organizations/:organization_id", as: :organization do
        get "entitlement-set", action: :entitlements, :controller => "organizations"
        get "workspaces", action: :index, :controller => "workspaces"
        get "workspaces/:id", action: :show, :controller => "workspaces"
        get "runs/queue", action: :queue, :controller => "organizations"
      end
      resources :workspaces, :except => [:index] do
        member do
          post "actions/lock", action: :lock, :controller => "workspaces"
          post "actions/unlock", action: :unlock, :controller => "workspaces"
          match "state-versions", via: [:get, :post]
          get "current-state-version"
          get :runs
          post :configuration_versions, action: :create, :controller => "configuration_versions", path: "configuration-versions"
        end
      end

      resources :plans
      resources :applies
      resources :runs, :except => [:index] do
        member do
          post "actions/discard", action: :discard, :controller => "runs"
          post "actions/cancel", action: :cancel, :controller => "runs"
          post "actions/force-cancel", action: :force_cancel, :controller => "runs"
          post "actions/force-execute", action: :force_execute, :controller => "runs"
          get "configuration-version/download", action: :download, :controller => "configuration_versions", param: :run_id
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
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
