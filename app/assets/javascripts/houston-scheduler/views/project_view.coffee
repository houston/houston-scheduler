class Scheduler.ProjectView extends Backbone.View
  
  
  initialize: ->
    @tickets = @options.tickets
    @tickets.on 'change', _.bind(@render, @)
    @router = new Scheduler.Router(parent: @)
    
    Backbone.history.start()
    @render()
  
  
  ticketsWithBothEstimates: -> @tickets.withBothEstimates()
  ticketsUnableToEstimate: -> @tickets.unableToEstimate()
  
  ticketsWaitingForEffortEstimate: ->
    @tickets.select (ticket)->
      (+ticket.get('estimated_effort') == 0) && !ticket.get('unable_to_set_estimated_effort')
  
  ticketsWaitingForValueEstimate: ->
    @tickets.select (ticket)->
      (+ticket.get('estimated_value') == 0) && !ticket.get('unable_to_set_estimated_value')
  
  
  showTab: (view)->
    $(@el).empty().appendView(view)
  
  
  render: ->
    count = @ticketsUnableToEstimate().length
    $('.tickets-unable-to-estimate-count').html(count).toggleClass('zero', count == 0)
    
    count = @ticketsWaitingForEffortEstimate().length
    $('.tickets-without-effort-count').html(count).toggleClass('zero', count == 0)
    
    count = @ticketsWaitingForValueEstimate().length
    $('.tickets-without-value-count').html(count).toggleClass('zero', count == 0)
