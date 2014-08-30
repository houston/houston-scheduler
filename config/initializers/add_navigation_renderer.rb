Houston.config.add_navigation_renderer :scheduler do
  projects = followed_projects.select { |project| can?(:read, project) }
  return nil if projects.empty?
  
  menu_items = []
  if config.use_mixer?
    menu_items << MenuItem.new("Mixer", Houston::Scheduler::Engine.routes.url_helpers.mixer_path)
    menu_items << MenuItemDivider.new
  end
  menu_items.concat projects.map { |project| ProjectMenuItem.new(project, Houston::Scheduler::Engine.routes.url_helpers.project_path(project)) }
  menu_items
  
  render_nav_menu "Scheduler", icon: "fa-calendar-o", items: menu_items
end
