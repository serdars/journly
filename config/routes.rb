Xplan::Application.routes.draw do
  root :to => "plans#index"
  match 'plans/:plan_id/items' => 'items#show', :via => :get
  match 'plans/:plan_id/items' => 'items#create', :via => :post
end
