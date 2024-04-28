Rails.application.routes.draw do
  devise_for :users

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

  end

  match "org_selector" => "organizations#selector", as: :organization_selector, via: [:get, :post]
  namespace :api do
    namespace :v1 do
      resources :workspaces do
        member do
          post "actions/lock"
          post "actions/unlock"
          get "state-versions"
          get "current-state-version"
          get :runs
        end
      end
      resources :plans
      resources :applies
      resources :runs
      resources :agents
      resources :configuration_versions
    end

    get :ping
  end
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
