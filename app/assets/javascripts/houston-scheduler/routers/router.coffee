class Scheduler.Router extends Backbone.Router
  
  routes:
    '':                   'showSequence2'
    'sequence2':          'showSequence2'
    'unable-to-estimate': 'showUnableToEstimate'
    'estimate-effort':    'showTicketsWithNoEffort'
  
  
  initialize: (options)->
    @parent = options.parent
  
  
  showSequence2: ->
    @activateTab('#sequence2')
    @show new Scheduler.Sequence2View
      project: @parent.project
      tickets: @parent.tickets
      velocity: @parent.velocity
      readonly: !@parent.canPrioritize
  
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
