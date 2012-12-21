require 'houston/scheduler/engine'

module Houston
  module Scheduler
    extend self
    
    
    def menu_items
      [ ["Demo", Engine.routes.url_helpers.demo_path] ]
    end
    
    def menu_item_for_project(project)
      Engine.routes.url_helpers.project_path(project)
    end
    
    
  end
end
