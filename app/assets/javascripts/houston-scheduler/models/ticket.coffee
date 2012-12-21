class Scheduler.Ticket extends Backbone.Model
  urlRoot: '/tickets'
  
  validate: (attributes)->
    return 'estimated_effort can not be negative' if attributes.estimated_effort && attributes.estimated_effort < 0
    return 'estimated_value can not be negative' if attributes.estimated_value && attributes.estimated_value < 0

class Scheduler.Tickets extends Backbone.Collection
  model: Scheduler.Ticket
  
  withNoValueEstimate: ->
    @select (ticket)-> +ticket.get('estimated_value') == 0
    
  withNoEffortEstimate: ->
    @select (ticket)-> +ticket.get('estimated_effort') == 0
  
  withBothEstimates: ->
    @select (ticket)-> (+ticket.get('estimated_value') > 0) && (+ticket.get('estimated_effort') > 0)
