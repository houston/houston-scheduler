Houston::Scheduler::Engine.routes.draw do
  
  get "mixer", :to => "mixer#index", :as => :mixer
  put "mixer", :to => "mixer#update"
  
  get "by_project/:slug", :to => "scheduler#project", :as => :project
  put "by_project/:slug/ticket_order", :to => "tickets#update_order"
  
  put "projects/:id/value_statements", :to => "value_statements#update"
  
  put "tickets/:id", :to => "tickets#update", constraints: {id: /\d+/}
  match "tickets/:id", :to => "tickets#update", constraints: {id: /\d+/}, via: "PATCH"
  
  get "milestones/:id", :to => "milestones#show", constraints: {id: /\d+/}
  delete "milestones/:id", :to => "milestones#close", constraints: {id: /\d+/}
  post "milestones", :to => "milestones#create"
  
  get "velocity", :to => "velocity#index"
  
end
