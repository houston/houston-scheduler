class Scheduler.Router extends Backbone.Router
  
  routes:
    '':                   'showSequence'
    'sequence':           'showSequence'
    'estimate-effort':    'showTicketsWithNoEffort'
    'estimate-value':     'showTicketsWithNoValue'
  
  
  initialize: (options)->
    @parent = options.parent
  
  
  showSequence: ->
    @activateTab('#sequence')
    @show new Scheduler.SequenceView(tickets: @parent.ticketsWithBothEstimates())
  
  showTicketsWithNoEffort: ->
    @updateActiveTab()
    @show new Scheduler.EditTicketEffortView(tickets: @parent.ticketsWithNoEffort())
  
  showTicketsWithNoValue: ->
    @updateActiveTab()
    @show new Scheduler.EditTicketValueView(tickets: @parent.ticketsWithNoValue())
  
  
  show: (view)->
    @parent.showTab(view)
  
  updateActiveTab: ->
    @activateTab(window.location.hash)
  
  activateTab: (hash)->
    $('.active').removeClass('active')
    $("a[href=\"#{hash}\"]").parent().addClass('active')
