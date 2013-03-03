class Scheduler.ProjectView extends Backbone.View
  
  
  events:
    'click .nav > li': 'selectTab'
  
  
  
  initialize: ->
    @tickets = @options.tickets
    @tickets.on 'change', _.bind(@render, @)
    @router = new Scheduler.Router(parent: @)
    
    Backbone.history.start()
    @render()
  
  
  ticketsWithBothEstimates: -> @tickets.withBothEstimates()
  ticketsWithNoEffort: -> @tickets.withNoEffortEstimate()
  ticketsWithNoValue: -> @tickets.withNoValueEstimate()
  
  
  
  showTab: (view)->
    $(@el).empty().appendView(view)
  
  
  render: ->
    count = @ticketsWithNoEffort().length
    $('.tickets-without-effort-count').html(count).toggleClass('zero', count == 0)
    
    count = @ticketsWithNoValue().length
    $('.tickets-without-value-count').html(count).toggleClass('zero', count == 0)
  
  
  selectTab: (e)->
    
