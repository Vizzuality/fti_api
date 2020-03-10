# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self) rescue ActiveAdmin::DatabaseHitDuringLoad

  root to: "home#index"

  scope module: :v1, constraints: APIVersion.new(version: 1, current: true) do
    # Account
    post  '/login',                       to: 'sessions#create'
    post  '/register',                    to: 'registrations#create'
    post  '/reset-password',              to: 'passwords#create'
    post  '/users/password',              to: 'passwords#update_by_token'
    patch '/users/current-user/password', to: 'passwords#update'

    # Helper requests
    get '/users/current-user',  to: 'users#current'

    scope '(:locale)', locale: /en|fr/ do
      # Resources
      jsonapi_resources :users do; end
      jsonapi_resources :countries do; end
      jsonapi_resources :categories do; end
      jsonapi_resources :subcategories do; end
      jsonapi_resources :severities do; end
      jsonapi_resources :laws do; end
      jsonapi_resources :species do; end
      jsonapi_resources :operators do; end
      jsonapi_resources :governments do; end
      jsonapi_resources :observers do; end
      jsonapi_resources :observations do; end
      jsonapi_resources :observation_documents do; end
      jsonapi_resources :observation_reports do; end
      jsonapi_resources :operator_documents, except: [:create, :update] do; end
      jsonapi_resources :operator_document_fmus do; end
      jsonapi_resources :operator_document_countries do; end
      jsonapi_resources :required_operator_documents do; end
      jsonapi_resources :required_operator_document_groups do; end
      jsonapi_resources :partners do; end
      jsonapi_resources :donors do; end
      jsonapi_resources :operator_document_annexes do; end
      jsonapi_resources :sawmills do; end
      jsonapi_resources :faqs, only: [:index, :show] do; end
      jsonapi_resources :tutorials, only: [:index, :show] do; end
      jsonapi_resources :how_tos, only: [:index, :show] do; end
      jsonapi_resources :tools, only: [:index, :show] do; end
      jsonapi_resources :required_gov_documents do; end
      jsonapi_resources :gov_documents do; end
      jsonapi_resources :gov_files, only: [:create, :destroy] do; end
      resources :fmus, only: [:index, :update] do
        get 'tiles/:z/:x/:y', to: 'fmus#tiles', on: :collection
      end
      resources :contacts, only: [:create, :index]

      resources :imports, only: :create

      get 'observation_filters', to: 'observation_filters#index'
    end

    # Documentation
    mount Rswag::Api::Engine => 'docs'
    mount Rswag::Ui::Engine => 'docs'
  end
end
