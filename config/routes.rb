Xplan::Application.routes.draw do
  root :to => "users#home"

  # Users
  devise_for :users, :controllers => { :registrations => "users/registrations"}
  match 'home' => 'users#home', :via => :get
  match 'user' => 'users#user', :via => :get

  # Plans
  match 'plans' => 'plans#index', :via => :get
  match 'plans' => 'plans#create', :via => :post
  match 'plans/:id' => 'plans#show', :via => :get
  match 'plans/:id' => 'plans#update', :via => :post
  match 'plans/:id' => 'plans#destroy', :via => :delete

  # Items
  match 'items' => 'items#index', :via => :get
  match 'items' => 'items#create', :via => :post
  match 'items/:id' => 'items#update', :via => :post
  match 'items/:id' => 'items#destroy', :via => :delete
  
  # Global
  match 'suggest' => 'items#suggest', :via => :get
  match 'info' => 'items#info', :via => :get
end
