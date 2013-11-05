Xplan::Application.routes.draw do
  root :to => "plans#index"
  match 'items' => 'items#index', :via => :get
  match 'items' => 'items#create', :via => :post
  match 'items/:id' => 'items#destroy', :via => :delete
  match 'suggest' => 'items#suggest', :via => :get
end
