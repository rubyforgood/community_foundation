Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resource :home
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ]
  resource :email_confirmation, only: %i[ new create show ]
  resource :magic_link, only: %i[ new create show ]
  namespace :users do
    resource :password, only: %i[ show update ]
    resource :email, only: %i[ show update ] do
      get :confirm, on: :member
    end
    resource :profile, only: %i[ show update ]
  end
  resource :session

  # Dev-only convenience: sign in as the first user without a password
  get "auto_sign_in", to: "auto_sign_in#create" if Rails.env.development?

  resource :organization, only: %i[ edit update ]
  resources :organization_memberships, only: %i[ index update ]
  resources :scenarios do
    resource :name, only: %i[ show edit update ], module: :scenarios
    resource :total_giving_amount, only: %i[ show edit update ], module: :scenarios
    resources :allocations, only: %i[ create update destroy ]
  end

  namespace :admin do
    resource :dashboard, only: :show
    resources :scenarios, only: :index
    resources :allocation_categories, only: %i[ index new create edit update destroy ]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#show"
end
