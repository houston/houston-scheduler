class Scheduler.Router extends Backbone.Router
  
  routes:
    '':                   'showSequence'
    'sequence':           'showSequence'
    'milestones':         'showMilestones'
    'unable-to-estimate': 'showUnableToEstimate'
    'estimate-effort':    'showTicketsWithNoEffort'
  
  
  initialize: (options)->
    @parent = options.parent
  
  
  showSequence: ->
    @activateTab('#sequence')
    @show new Scheduler.SequenceView
      project: @parent.project
      tickets: @parent.tickets
      velocity: @parent.velocity
      readonly: !@parent.canPrioritize
  
  showMilestones: ->
    @activateTab('#milestones')
    @show new Scheduler.MilestonesView
      project: @parent.project
      milestones: @parent.milestones
    
  showUnableToEstimate: ->
    @updateActiveTab()
    @show new Scheduler.UnableToEstimateView
      tickets: @parent.ticketsUnableToEstimate()
      readonly: !@parent.canEstimate
  
  showTicketsWithNoEffort: ->
    @updateActiveTab()
    @show new Scheduler.EditTicketEffortView(tickets: @parent.tickets)
  
  
  show: (view)->
    @parent.showTab(view)
  
  updateActiveTab: ->
    @activateTab(window.location.hash)
  
  activateTab: (hash)->
    $('.active').removeClass('active')
    $("a[href=\"#{hash}\"]").parent().addClass('active')
