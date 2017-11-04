Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root "admin/groups#index"

  namespace :admin do 
    resources :groups, :only => [:index, :destroy, :create, :edit, :update]
    resources :groups do
      member do
        get 'run_test'
      end
    end

    # Users
    resources :users, :only => [:index, :create, :destroy, :edit, :update]

    resources :tests, :only => [:show]
  end
end
