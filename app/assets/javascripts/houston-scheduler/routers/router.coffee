class Scheduler.Router extends Backbone.Router
  
  routes:
    '':                   'showSequence'
    'sequence':           'showSequence'
    'milestones':         'showMilestones'
    'unable-to-estimate': 'showUnableToEstimate'
    'estimate-effort':    'showTicketsWithNoEffort'
    'planning-poker':     'showPlanningPoker'
  
  
  initialize: (options)->
    @parent = options.parent
  
  
  reload: ->
    location = window.location.hash.replace(/^#?\/?/, '').replace(/\?.*/, '')
    method = @routes[location]
    if method
      console.log "[router] refreshing #{location}"
      @[method]()
    else
      console.log "[router] unable to refresh #{location}"
  
  
  showSequence: ->
    @activateTab('#sequence')
    @show new Scheduler.SequenceView
      project: @parent.project
      tickets: @parent.ticketsReadyToPrioritize()
      velocity: @parent.velocity
      readonly: !@parent.canPrioritize
  
  showMilestones: ->
    @activateTab('#milestones')
    @show new Scheduler.MilestonesView
      project: @parent.project
      tickets: @parent.tickets
      milestones: @parent.milestones
      readonly: !@parent.canPrioritize
    
  showUnableToEstimate: ->
    @updateActiveTab()
    @show new Scheduler.UnableToEstimateView
      tickets: @parent.ticketsWaitingForDiscussion()
      canEstimate: @parent.canEstimate
      canPrioritize: @parent.canPrioritize
  
  showTicketsWithNoEffort: ->
    @updateActiveTab()
    @show new Scheduler.EditTicketEffortView
      tickets: @parent.openTickets()
  
  showPlanningPoker: ->
    @updateActiveTab()
    @show new Scheduler.PlanningPoker
      tickets: @parent.ticketsWaitingForEffortEstimate()
      maintainers: @parent.maintainers
  
  
  show: (view)->
    @parent.showTab(view)
  
  updateActiveTab: ->
    @activateTab(window.location.hash)
  
  activateTab: (hash)->
    $('.active').removeClass('active')
    $("a[href=\"#{hash}\"]").parent().addClass('active')
