class Scheduler.Ticket extends Backbone.Model
  urlRoot: '/scheduler/tickets'
  
  validate: (attributes)->
    return 'estimatedEffort can not be negative' if attributes.estimatedEffort && attributes.estimatedEffort < 0
    return 'estimatedValue can not be negative' if attributes.estimatedValue && attributes.estimatedValue < 0

class Scheduler.Tickets extends Backbone.Collection
  model: Scheduler.Ticket
  
  sorted: -> _.sortBy @withSequence(), (ticket)-> +ticket.get('sequence')
  withSequence: ->
    @select (ticket)-> !!ticket.get('sequence')
  
  unsorted: -> @withoutSequence()
  withoutSequence: ->
    @select (ticket)-> !ticket.get('sequence')
  
  unableToEstimate: ->
    @select (ticket)->
      ticket.get('unableToSetEstimatedEffort') or ticket.get('unableToSetEstimatedValue')
  
  withBothEstimates: ->
    @select (ticket)-> (+ticket.get('estimatedValue') > 0) && (+ticket.get('estimatedEffort') > 0)
  
  withEffortEstimate: ->
    @select (ticket)-> +ticket.get('estimatedValue') > 0
