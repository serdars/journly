Xplan::Application.routes.draw do
  root :to => "plans#index"
  # Plans
  match 'plans' => 'plans#index', :via => :get
  match 'plans' => 'plans#create', :via => :post

  # Items
  match 'items' => 'items#index', :via => :get
  match 'items' => 'items#create', :via => :post
  match 'items/:id' => 'items#update', :via => :post
  match 'items/:id' => 'items#destroy', :via => :delete
  
  # Global
  match 'suggest' => 'items#suggest', :via => :get
  match 'info' => 'items#info', :via => :get
end
