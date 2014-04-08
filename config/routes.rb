Houston::Scheduler::Engine.routes.draw do
  
  get "mixer", :to => "mixer#index", :as => :mixer
  put "mixer", :to => "mixer#update"
  
  get "by_project/:slug", :to => "scheduler#project", :as => :project
  put "by_project/:slug/ticket_order", :to => "tickets#update_order"
  
  put "tickets/:id", :to => "tickets#update", constraints: {id: /\d+/}
  match "tickets/:id", :to => "tickets#update", constraints: {id: /\d+/}, via: "PATCH"
  
  get "milestones/:id", :to => "milestones#show", constraints: {id: /\d+/}
  delete "milestones/:id", :to => "milestones#close", constraints: {id: /\d+/}
  post "milestones", :to => "milestones#create"
  
  get "sprints/current", :to => "sprints#current", :as => :current_sprint
  get "sprints/:id", :to => "sprints#show", constraints: {id: /\d+/}, :as => :sprint
  post "sprints/:id/tickets/:ticket_id", :to => "sprints#add_ticket", constraints: {id: /\d+/, ticket_id: /\d+/}
  delete "sprints/:id/tickets/:ticket_id", :to => "sprints#remove_ticket", constraints: {id: /\d+/, ticket_id: /\d+/}
  
  post "tickets/:id/lock", :to => "ticket_locks#create", constraints: {id: /\d+/}
  delete "tickets/:id/lock", :to => "ticket_locks#destroy", constraints: {id: /\d+/}
  
end
