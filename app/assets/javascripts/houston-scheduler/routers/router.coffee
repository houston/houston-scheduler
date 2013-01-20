class Scheduler.Router extends Backbone.Router
  
  routes:
    'schedule':         'showScheduler'
    'estimate-effort':  'showTicketsWithNoEffort'
    'estimate-value':   'showTicketsWithNoValue'
  
  
  initialize: (options)->
    @parent = options.parent
  
  
  showScheduler: ->
    $('.active').removeClass('active')
    $('a[href="#schedule"]').parent().addClass('active')
    @show new Scheduler.ScheduleView(tickets: @parent.ticketsWithBothEstimates())
    
  showTicketsWithNoEffort: ->
    $('.active').removeClass('active')
    $('a[href="#estimate-effort"]').parent().addClass('active')
    @show new Scheduler.EditTicketEffortView(tickets: @parent.ticketsWithNoEffort())
  
  showTicketsWithNoValue: ->
    $('.active').removeClass('active')
    $('a[href="#estimate-value"]').parent().addClass('active')
    @show new Scheduler.EditTicketValueView(tickets: @parent.ticketsWithNoValue())
  
  
  show: (view)->
    @parent.showTab(view)
  
