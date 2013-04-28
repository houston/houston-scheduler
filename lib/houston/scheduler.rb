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
      
      menu_items = []
      menu_items << MenuItem.new("Mixer", Engine.routes.url_helpers.mixer_path)
      menu_items << MenuItem.new("Demo", Engine.routes.url_helpers.demo_path) if user.administrator?
      menu_items << MenuItemDivider.new
      menu_items.concat projects.map { |project| ProjectMenuItem.new(project, Engine.routes.url_helpers.project_path(project)) }
      menu_items
    end
    
    
  end
end
