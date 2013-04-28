class Scheduler.MixerView extends Backbone.View
  
  events:
    'click .mixer-inactive-project': 'addToActiveProjects'
    'click .remove-from-active-projects': 'removeFromActiveProjects'
  
  initialize: ->
    @projects = @options.projects
    @readonly = @options.readonly
    @$el = $('#mixer_view')
    @el = @$el[0]
    @renderActiveProject = HandlebarsTemplates['houston-scheduler/mixer/active_project']
    @renderInactiveProject = HandlebarsTemplates['houston-scheduler/mixer/inactive_project']
  
  loadMix: (mix)->
    @throttleByProjectId = mix
    @render()
  
  render: ->
    @$el.html '''
      <div class="active-projects">
        <h6>Active Projects</h6>
        <div id="active_projects"></div>
      </div>
      
      <div class="inactive-projects">
        <h6>Inactive Projects</h6>
        <div id="inactive_projects"></div>
      </div>
      '''
    
    @$activeProjects = @$el.find('#active_projects')
    @$inactiveProjects = @$el.find('#inactive_projects')
    
    @projects.each (project)=>
      throttle = @throttleByProjectId[project.id]
      if throttle
        @appendToActiveProjects(project, throttle)
      else
        @appendToInactiveProjects(project)
  
  appendToActiveProjects: (project, throttle)->
    $project = $ @renderActiveProject(_.extend(project, throttle: throttle))
    @$activeProjects.append $project
    $project.find('.mixer-throttle').slider
      range: "min"
      max: 100
      value: throttle,
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
      @throttleByProjectId[id] = 0
      @appendToActiveProjects(project, 0)
      @trigger 'change', @throttleByProjectId
  
  removeFromActiveProjects: (e)->
    e.preventDefault()
    $a = $(e.target).closest('a')
    id = +$a.attr('data-id')
    
    project = _.find @projects, (project)-> project.id == id
    if project
      $a.closest('.mixer-active-project').remove()
      @throttleByProjectId[id] = 0
      @appendToInactiveProjects(project)
      @trigger 'change', @throttleByProjectId
  
  
  
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
    
    @trigger 'change', @throttleByProjectId
    !coerced
  
  coercePercentOnChange: (e, ui)->
    @calculateMaxValueForSlider(e, ui)
    @coercePercent(e, ui)
    true
