Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root "admin/groups#index"

  namespace :admin do 
    
    # Groups
    resources :groups, :only => [:index, :destroy, :create, :edit, :update]
    resources :groups do
      member do
        post 'run_test'
        post 'run_otp_test'
        get 'geocode'
        post 'export_trips'
      end
    end

    # Trips
    resources :trips, :only => [:destroy, :create]

    # Results
    resources :results, :only => [:show]

    # Users
    resources :users, :only => [:index, :create, :destroy, :edit, :update]

    # Tests
    resources :tests, :only => [:show, :destroy]

    # Configs
    resources :configs, only: [:index]
    patch 'configs' => 'configs#update'
    patch 'config_atis_otp_mapping' => 'configs#update_atis_otp_mapping'
  end
end
