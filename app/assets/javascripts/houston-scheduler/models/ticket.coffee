class Scheduler.Ticket extends Backbone.Model
  urlRoot: '/scheduler/tickets'
  
  validate: (attributes)->
    return 'estimatedEffort can not be negative' if attributes.estimatedEffort && attributes.estimatedEffort < 0
    return 'estimatedValue can not be negative' if attributes.estimatedValue && attributes.estimatedValue < 0

class Scheduler.Tickets extends Backbone.Collection
  model: Scheduler.Ticket
  
  numbered: (numbers)->
    numbers = [] unless numbers
    numbers = [numbers] unless _.isArray(numbers)
    return [] unless numbers.length >= 1
    @select (ticket)-> ticket.get('number') in numbers
  
  sortedBySequence: ->
    @sortBy (ticket)=>
      (+ticket.get('sequence') <= 0) * 9999999 + # then tickets with no priority,
       +ticket.get('sequence')                   # finally sort by priority
  
  sorted: -> _.sortBy @withSequence(), (ticket)-> +ticket.get('sequence')
  withSequence: ->
    @select (ticket)-> !!ticket.get('sequence')
  
  unresolved: ->
    new Scheduler.Tickets(@select (ticket)-> !ticket.get('resolved'))
  
  unsorted: -> @withoutSequence()
  withoutSequence: ->
    @select (ticket)-> !ticket.get('sequence')
  
  withoutMilestones: ->
    @select (ticket)-> !ticket.get('milestoneId')
  
  withoutEffortEstimate: ->
    new Scheduler.Tickets(@select (ticket)-> +ticket.get('estimatedEffort') == 0)
  
  inSprint: (sprintId)->
    @select (ticket)-> ticket.get('sprintId') == sprintId
  
  ableToPrioritize: ->
    new Scheduler.Tickets(@select (ticket)-> !ticket.get('unableToSetPriority'))
  
  ableToEstimate: ->
    new Scheduler.Tickets(@select (ticket)-> !ticket.get('unableToSetEstimatedEffort'))
  
  waitingForDiscussion: ->
    new Scheduler.Tickets(@select (ticket)->
      ticket.get('unableToSetEstimatedEffort') or ticket.get('unableToSetPriority'))
  
  withBothEstimates: ->
    @select (ticket)-> (+ticket.get('estimatedValue') > 0) && (+ticket.get('estimatedEffort') > 0)
