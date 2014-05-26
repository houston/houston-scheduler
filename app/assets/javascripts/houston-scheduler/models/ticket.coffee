class Scheduler.Ticket extends Backbone.Model
  urlRoot: '/scheduler/tickets'
  
  tasks: -> @_tasks ?= new Scheduler.Tasks(@get('tasks'))
  estimatedEffort: ->
    effort = @tasks().reduce ((sum, task)-> sum + +task.get('effort')), 0
    if effort == 0 then null else effort
  estimated: -> @tasks().every (task)-> +task.get('effort') > 0
  
  addTask: (attributes)->
    xhr = $.post "/scheduler/tickets/#{@id}/tasks", attributes
    xhr.success (tasks)=>
      @_tasks = null
      @set('tasks', tasks)
    xhr
  
  deleteTask: (task)->
    xhr = $.destroy "/scheduler/tasks/#{task.id}"
    xhr.success (tasks)=>
      @_tasks = null
      @set('tasks', tasks)
    xhr
  
  nextTaskNumber: ->
    _.max(@tasks().pluck('number')) + 1
  
  nextTaskLetter: ->
    bytes = []
    remaining = @nextTaskNumber()
    while remaining > 0
      bytes.unshift (remaining - 1) % 26 + 97
      remaining = Math.round((remaining - 1) / 26)
    String.fromCharCode(bytes)
  
  parse: (ticket)->
    if ticket.extendedAttributes
      ticket.sequence = +ticket.extendedAttributes['sequence']
      ticket.sequence = null if !ticket.sequence
      ticket.unableToSetEstimatedEffort = ticket.extendedAttributes['unable_to_set_estimated_effort']
      ticket.unableToSetPriority = ticket.extendedAttributes['unable_to_set_priority']
      ticket.postponed = ticket.extendedAttributes['postponed']
      for key, value of ticket
        if key.match(/estimated_effort\[\d+\]/)
          ticket[key.replace(/estimated_effort/, 'estimatedEffort')] = value
    ticket



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
  withSequence: -> @select (ticket)-> !!ticket.get('sequence')
  unresolved: -> new Scheduler.Tickets(@select (ticket)-> !ticket.get('resolved'))
  unsorted: -> @withoutSequence()
  withoutSequence: -> @select (ticket)-> !ticket.get('sequence')
  withoutMilestones: -> @select (ticket)-> !ticket.get('milestoneId')
  
  withoutEffortEstimate: ->
    new Scheduler.Tickets(@select (ticket)-> !ticket.estimated())
  
  ableToPrioritize: ->
    new Scheduler.Tickets(@select (ticket)-> !ticket.get('unableToSetPriority'))
  
  ableToEstimate: ->
    new Scheduler.Tickets(@select (ticket)-> !ticket.get('unableToSetEstimatedEffort'))
  
  waitingForDiscussion: ->
    new Scheduler.Tickets(@select (ticket)->
      ticket.get('unableToSetEstimatedEffort') or ticket.get('unableToSetPriority'))
  
  withBothEstimates: ->
    @select (ticket)-> (+ticket.get('estimatedValue') > 0) && ticket.estimatedEffort() > 0

  postponed: ->
    new Scheduler.Tickets(@select (ticket)-> !!ticket.get('postponed'))

  unpostponed: ->
    new Scheduler.Tickets(@select (ticket)-> !ticket.get('postponed'))
