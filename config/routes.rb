PowerControlServer::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'application#index'
  
  post "application/login"
  post "application/logout"
  get "application/logout"
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  get "admin/main"
  get "admin/users"
  get "admin/user_edit/:username", :to => 'admin#user_edit'
  get "admin/user_edit"
  post "admin/user_write"
  get "admin/devices"
  get "admin/device_edit/:dev_id", :to => 'admin#device_edit'
  get "admin/device_edit"
  post "admin/device_write"
  get "admin/main"
  post "admin/map_write"
  get "admin/param_edit"
  post "admin/param_write"
  get "user/main"
  get "user/data"
  get "admin/fuelcodes"
  post "admin/fuelcodes_add"
  get "admin/gpx"
  get "admin/yandex"

  post "device/p"
  post "device/reg"
  post "device/fuel"
  post "device/repair"
  get "device/track"

  get "admin/fuel_upgrade_edit"
  get "admin/upgrade_edit"
  post "admin/upgrade_write"
  get "admin/upgrade_delete"

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
