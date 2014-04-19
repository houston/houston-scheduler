require "houston/scheduler/engine"
require "houston/scheduler/configuration"

module Houston
  module Scheduler
    extend self
    
    attr_reader :config
    
    def menu_items_for(context={})
      projects = context[:projects]
      ability = context[:ability]
      user = context[:user]
      
      projects = projects.select { |project| ability.can?(:read, project) }
      return [] if projects.empty?
      
      menu_items = []
      menu_items << MenuItem.new("Mixer", Engine.routes.url_helpers.mixer_path) if config.use_mixer?
      menu_items << MenuItem.new("Sprint", Engine.routes.url_helpers.current_sprint_path) if ability.can?(:read, Sprint.new)
      
      menu_items << MenuItemDivider.new
      menu_items.concat projects.map { |project| ProjectMenuItem.new(project, Engine.routes.url_helpers.project_path(project)) }
      menu_items
    end
    
  end
  
  Scheduler.instance_variable_set :@config, Scheduler::Configuration.new
end
