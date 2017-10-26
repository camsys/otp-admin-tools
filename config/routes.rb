Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root "admin/groups#index"

  namespace :admin do 
    resources :groups, :only => [:index, :destroy, :create, :edit, :update]
    resources :tests, :only => [:show]
  end
end
