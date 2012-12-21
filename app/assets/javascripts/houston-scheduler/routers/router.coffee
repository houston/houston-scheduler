class Scheduler.Router extends Backbone.Router
  
  routes:
    '':           'showScheduler'
    'no-effort':  'showTicketsWithNoEffort'
    'no-value':   'showTicketsWithNoValue'
  
  
  initialize: (options)->
    @parent = options.parent
  
  
  showScheduler: ->
    $('.active').removeClass('active')
    $('a[href="#"]').parent().addClass('active')
    @show new Scheduler.ScheduleView(tickets: @parent.ticketsWithBothEstimates())
    
  showTicketsWithNoEffort: ->
    $('.active').removeClass('active')
    $('a[href="#no-effort"]').parent().addClass('active')
    @show new Scheduler.EditTicketEffortView(tickets: @parent.ticketsWithNoEffort())
  
  showTicketsWithNoValue: ->
    $('.active').removeClass('active')
    $('a[href="#no-value"]').parent().addClass('active')
    @show new Scheduler.EditTicketValueView(tickets: @parent.ticketsWithNoValue())
  
  
  show: (view)->
    @parent.showTab(view)
  
