Cadastro::Application.routes.draw do

  devise_for :admins, :controllers => {:sessions => 'sessions'}
  devise_scope :admin do
    get "/admin" => 'devise/sessions#new', :as => :new_admin_session
    delete "/logoutadmin" => "devise/sessions#destroy", :as => :destroy_admin_session
  end

  namespace :admin do
    resources :republicas do
      resources :moradores
      resources :atributos
      resources :exmoradores
      put 'approve'
      put 'disapprove'
      get "statistics"
      get 'send_reconfirmation'
    end
    resources :dashboard, except: [:show, :edit, :new, :update, :destroy]

    namespace :dashboard do
      get 'listadereps'
    end

    resources :categorias
    resources :servicos do
      resources :comentarios, only: [:index, :edit, :destroy]
    end
  end

  devise_for :republicas, :controllers => {:registrations => 'registrations'}
  devise_scope :republica do
    get "/login" => "devise/sessions#new", :as => :new_republica_session 
    delete "/logout" => "devise/sessions#destroy", :as => :destroy_republica_session
  end

  get "sistema/index"
  
  resources :republicas, except: [:edit, :update] do
    resources :exmoradores, only: [:index, :new, :create]
    get 'moradores/edit', to: 'moradores#edit'
    put 'moradores', to: 'moradores#update'
    resources :moradores, except: [:show, :edit, :update]
    resource :contato, only: [:edit, :update]
    resource :social_information, only: [:edit, :update]
    resource :vaga, only: [:update]
  end

  namespace :republicas do
    put 'send_reconfirmation'
  end

  get "/terms" => "sistema#terms", :as => :terms

  authenticated :user do
    root :to => 'sistema#index'
  end

  resources :categorias
  resources :servicos do
    resources :comentarios, only: [:index, :edit, :new, :create]
  end


  #resources :user_steps

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'sistema#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
