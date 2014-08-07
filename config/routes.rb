Houston::Scheduler::Engine.routes.draw do
  
  get "mixer", :to => "mixer#index", :as => :mixer
  put "mixer", :to => "mixer#update"
  
  get "by_project/:slug", :to => "scheduler#project", :as => :project
  put "by_project/:slug/ticket_order", :to => "tickets#update_order"
  
  put "projects/:id/value_statements", :to => "value_statements#update"
  
  put "tickets/:id", :to => "tickets#update", constraints: {id: /\d+/}
  match "tickets/:id", :to => "tickets#update", constraints: {id: /\d+/}, via: "PATCH"
  
  post "tickets/:id/tasks", :to => "tasks#create", constraints: {id: /\d+/}
  put "tasks/:id", :to => "tasks#update", constraints: {id: /\d+/}
  match "tasks/:id", :to => "tasks#update", constraints: {id: /\d+/}, via: "PATCH"
  delete "tasks/:id", :to => "tasks#destroy", constraints: {id: /\d+/}
  
  get "velocity", :to => "velocity#index"
  
end
