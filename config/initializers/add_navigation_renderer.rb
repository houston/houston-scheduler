# Houston.add_navigation_renderer :scheduler do
#   projects = followed_projects.select { |project| can?(:read, project) }
#   unless projects.empty?
#     menu_items = []
#     if config.use_mixer?
#       menu_items << MenuItem.new("Mixer", Houston::Scheduler::Engine.routes.url_helpers.mixer_path)
#       menu_items << MenuItemDivider.new
#     end
#     menu_items.concat projects.map { |project| ProjectMenuItem.new(project, Houston::Scheduler::Engine.routes.url_helpers.project_path(project)) }
#     menu_items
#
#     render_nav_menu "Scheduler", icon: "fa-calendar-o", items: menu_items
#   end
# end

Houston.add_project_feature :scheduler do
  name "Scheduler"
  icon "fa-calendar-o"
  path { |project| Houston::Scheduler::Engine.routes.url_helpers.project_path(project) }
end
