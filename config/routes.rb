Houston::Scheduler::Engine.routes.draw do
  
  root :to => "scheduler#index", :as => :demo
  
  get "by_project/:slug", :to => "scheduler#project", :as => :project
  
  put "tickets/:id", :to => "tickets#update"
  
end
