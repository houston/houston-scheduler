require 'houston/scheduler/engine'

module Houston
  module Scheduler
    extend self
    
    
    def menu_items_for(context={})
      projects = context[:projects]
      ability = context[:ability]
      user = context[:user]
      
      projects = projects.select { |project| ability.can?(:read, project) }
      return [] if projects.empty?
      
      menu_items = projects.map { |project| ProjectMenuItem.new(project, Engine.routes.url_helpers.project_path(project)) }
      menu_items = [ MenuItem.new("Demo", Engine.routes.url_helpers.demo_path), MenuItemDivider.new ] + menu_items if user.administrator?
      menu_items
    end
    
    
  end
end
