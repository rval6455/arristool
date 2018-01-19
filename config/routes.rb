# Rails.application.routes.draw do
#   # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
# end

ArrisTool::Application.routes.draw do
  resources :arris_headends

	match '/report', to: 'cmts#report', via: 'get'
	match '/sweep', to: 'cmts#sweep', via: 'get'
  match '/managec3' => 'cmts#managec3', via: 'get'
	match '/showcablemodems' => 'cmts#scm', via: 'get'
  match '/scmsum' => 'cmts#scmsum', via: 'get'
	match '/scmdetail' => 'cmts#scmdetail', via: 'get'
  match '/schdetail' => 'cmts#schdetail', via: 'get'
  match '/hostmaclookup' => 'cmts#hostmaclookup', via: 'get'
  match '/showrun' => 'cmts#showrun', via: 'get'
  match '/showflaplist' => 'cmts#showflaplist', via: 'get'
	match '/showcontrollers' => 'cmts#showcontrollers', via: 'get'
  match '/showenvironment' => 'cmts#showenvironment', via: 'get'
  match '/deleteoffline' => 'cmts#deleteoffline', via: 'get'
  match '/resetmodemcounters' => 'cmts#resetmodemcounters', via: 'get'
  match '/clearflaplist' => 'cmts#clearflaplist', via: 'get'
  match '/plat' => 'cmts#showplatinfo', via: 'get'

  resources :cmts

  root :to => 'cmts#index'

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
