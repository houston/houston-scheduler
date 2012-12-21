Houston::Scheduler::Engine.routes.draw do
  
  root :to => "scheduler#index", :as => :demo
  
  match "by_project/:slug", :to => "scheduler#project", :as => :project
  
end
