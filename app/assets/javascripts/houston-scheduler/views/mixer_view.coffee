class Scheduler.MixerView extends Backbone.View
  
  events:
    'click .mixer-inactive-project': 'addToActiveProjects'
    'click .remove-from-active-projects': 'removeFromActiveProjects'
  
  initialize: ->
    @projects = @options.projects
    @$el = $('#mixer_view')
    @el = @$el[0]
    
    @$activeProjects = @$el.find('#active_projects')
    @$inactiveProjects = @$el.find('#inactive_projects')
    
    @throttleByProjectId = {}
    
    @renderActiveProject = HandlebarsTemplates['houston-scheduler/mixer/active_project']
    @renderInactiveProject = HandlebarsTemplates['houston-scheduler/mixer/inactive_project']
    
    @render()
    
  render: ->
    @projects.each (project)=>
      if project.active
        @appendToActiveProjects(project)
      else
        @appendToInactiveProjects(project)
  
  appendToActiveProjects: (project)->
    $project = $ @renderActiveProject(project)
    @$activeProjects.append $project
    $project.find('.mixer-throttle').slider
      range: "min"
      max: 100
      value: 0
      start: _.bind(@calculateMaxValueForSlider, @)
      slide: _.bind(@coercePercent, @)
      change: _.bind(@coercePercentOnChange, @)
  
  appendToInactiveProjects: (project)->
    $project = @renderInactiveProject(project)
    @$inactiveProjects.append $project
  
  
  
  addToActiveProjects: (e)->
    e.preventDefault()
    $a = $(e.target).closest('a')
    id = +$a.attr('data-id')
    project = _.find @projects, (project)-> project.id == id
    if project
      $a.closest('.mixer-inactive-project').remove()
      @appendToActiveProjects(project)
  
  removeFromActiveProjects: (e)->
    e.preventDefault()
    $a = $(e.target).closest('a')
    id = +$a.attr('data-id')
    
    project = _.find @projects, (project)-> project.id == id
    if project
      $a.closest('.mixer-active-project').remove()
      delete @throttleByProjectId[id]
      @appendToInactiveProjects(project)
  
  
  
  calculateMaxValueForSlider: (e, {handle})->
    $project = $(handle).closest('.mixer-active-project')
    id = +$project.attr('data-id')
    @maxValueForSlider = @calculateMaxValueForProject(id)
  
  calculateMaxValueForProject: (id)->
    maxValue = 100
    maxValue -= value for projectId, value of @throttleByProjectId when +projectId isnt id
    maxValue
  
  coercePercent: (e, {handle, value})->
    coerced = false
    
    if value > @maxValueForSlider
      value = @maxValueForSlider
      $(handle).closest('.ui-slider').slider('value', value)
      coerced = true
    
    $project = $(handle).closest('.mixer-active-project')
    id = $project.attr('data-id')
    @throttleByProjectId[id] = value
    
    $project.find('.mixer-throttle-percentage').html(value)
    !coerced
  
  coercePercentOnChange: (e, ui)->
    @calculateMaxValueForSlider(e, ui)
    @coercePercent(e, ui)
    true
