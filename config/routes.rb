Xplan::Application.routes.draw do
  root :to => "plans#index"
  match 'items' => 'items#index', :via => :get
  match 'items' => 'items#create', :via => :post
end
