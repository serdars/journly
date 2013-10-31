Xplan::Application.routes.draw do
  root :to => "plans#index"
  match 'plans/:plan_id/items' => 'items#show', :via => :get
end
