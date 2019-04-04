Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root "static#index"

  resources :configs, only: [:index]
  patch 'configs' => 'configs#update'
  post 'configs' => 'configs#update'
  patch 'config_atis_otp_mapping' => 'configs#update_atis_otp_mapping'

  namespace :admin do 
    
    # Reports
    resources :reports, only: [:index] do
      collection do

        # DASHBOARD REPORTS
        get 'index'
        post 'index'
        get 'api_usage_dashboard'
        get 'origin_destination_dashboard'

      end
    end

    # Users
    resources :users, :only => [:index, :create, :destroy, :edit, :update]

  end

  ### JSON API ###
  namespace :api do

    ### API V1 (LEGACY) ###
    namespace :v1 do

      # Groups
      resources :groups, :only => [:show]
      resources :groups do 
        member do 
          post 'run'
        end
      end

    end
  end

  ### Trip Compare ###
  namespace :trip_compare do
    # Groups
    resources :groups, :only => [:index, :destroy, :create, :edit, :update]
    resources :groups do
      member do
        post 'run'
        get  'geocode'
        post 'export_trips'
      end
    end

    resources :results, :only => [:show]
    resources :tests, :only => [:show, :destroy]

    # Trips
    resources :trips, :only => [:destroy, :create, :edit, :update]
  
  end


  ### Station Visualizer ###
  namespace :stations do
    resources :stations do
      collection do
        get 'index'
        get 'get_station_from_api'
      end
    end
  end

  ### Static Websites ###
  get "/static/route_viz" => "static#show"



end
