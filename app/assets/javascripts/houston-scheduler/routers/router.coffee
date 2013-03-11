class Scheduler.Router extends Backbone.Router
  
  routes:
    '':                   'showSequence'
    'sequence':           'showSequence'
    'sequence2':          'showSequence2'
    'unable-to-estimate': 'showUnableToEstimate'
    'estimate-effort':    'showTicketsWithNoEffort'
    'estimate-value':     'showTicketsWithNoValue'
  
  
  initialize: (options)->
    @parent = options.parent
  
  
  showSequence: ->
    @activateTab('#sequence')
    @show new Scheduler.SequenceView(tickets: @parent.ticketsWithBothEstimates())
  
  showSequence2: ->
    @activateTab('#sequence2')
    @show new Scheduler.Sequence2View(tickets: @parent.ticketsWithEffortEstimate())
  
  showUnableToEstimate: ->
    @updateActiveTab()
    @show new Scheduler.UnableToEstimateView(tickets: @parent.ticketsUnableToEstimate())
  
  showTicketsWithNoEffort: ->
    @updateActiveTab()
    @show new Scheduler.EditTicketEffortView(tickets: @parent.tickets)
  
  showTicketsWithNoValue: ->
    @updateActiveTab()
    @show new Scheduler.EditTicketValueView(tickets: @parent.tickets)
  
  
  show: (view)->
    @parent.showTab(view)
  
  updateActiveTab: ->
    @activateTab(window.location.hash)
  
  activateTab: (hash)->
    $('.active').removeClass('active')
    $("a[href=\"#{hash}\"]").parent().addClass('active')
