Rails.application.routes.draw do
  resources :pages #, only: [:new, :create, :show, :destroy]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "pages#new"
end
