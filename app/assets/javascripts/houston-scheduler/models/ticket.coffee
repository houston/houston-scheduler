class Scheduler.Ticket extends Backbone.Model
  urlRoot: '/scheduler/tickets'
  
  tasks: -> @_tasks ?= new Scheduler.Tasks(@get('tasks'))
  estimatedEffort: ->
    effort = @tasks().reduce ((sum, task)-> sum + +task.get('effort')), 0
    if effort == 0 then null else effort
  estimated: -> @tasks().every (task)-> +task.get('effort') > 0
  waitingForDiscussion: -> @get('unableToSetEstimatedEffort') or @get('unableToSetPriority')
  
  severity: ->
    seriousness = @get('seriousness')
    likelihood = @get('likelihood')
    clumsiness = @get('clumsiness')
    return false unless seriousness && likelihood && clumsiness
    (0.6 * seriousness + 0.3 * likelihood + 0.1 * clumsiness).toFixed(1)
  
  value: ->
    0
  
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
      
      ticket.seriousness = ticket.extendedAttributes['seriousness']
      ticket.likelihood = ticket.extendedAttributes['likelihood']
      ticket.clumsiness = ticket.extendedAttributes['clumsiness']
      
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
  unresolved: -> @scoped (ticket)-> !ticket.get('resolved')
  unsorted: -> @withoutSequence()
  withoutSequence: -> @select (ticket)-> !ticket.get('sequence')
  withoutMilestones: -> @select (ticket)-> !ticket.get('milestoneId')
  features: -> @scoped (ticket)-> ticket.get('type') == 'feature' || ticket.get('type') == 'enhancement'
  bugs: -> @scoped (ticket)-> ticket.get('type') == 'bug'
  withoutEffortEstimate: -> @scoped (ticket)-> !ticket.estimated()
  withSeverityEstimate: -> @scoped (ticket)-> !!ticket.severity()
  withoutSeverityEstimate: -> @scoped (ticket)-> !ticket.severity()
  withValueEstimate: -> @scoped (ticket)-> !!ticket.value()
  withoutValueEstimate: -> @scoped (ticket)-> !ticket.value()
  ableToPrioritize: -> @scoped (ticket)-> !ticket.get('unableToSetPriority')
  ableToEstimate: -> @scoped (ticket)-> !ticket.get('unableToSetEstimatedEffort')
  waitingForDiscussion: -> @scoped (ticket)-> ticket.waitingForDiscussion()
  postponed: -> @scoped (ticket)-> !!ticket.get('postponed')
  unpostponed: -> @scoped (ticket)-> !ticket.get('postponed')

  orderBy: (attribute, ascOrDesc)->
    tickets = @sortBy(@sorterFor(attribute))
    tickets = tickets.reverse() if ascOrDesc == 'desc'
    new Scheduler.Tickets(tickets)
  
  sorterFor: (attribute)->
    switch attribute
      when 'sequence'     then (ticket)-> +ticket.get('sequence')
      when 'effort'       then (ticket)-> ticket.estimatedEffort()
      when 'severity'     then (ticket)-> ticket.severity()
      when 'seriousness'  then (ticket)-> +ticket.get('seriousness')
      when 'likelihood'   then (ticket)-> +ticket.get('likelihood')
      when 'clumsiness'   then (ticket)-> +ticket.get('clumsiness')
      when 'summary'      then (ticket)-> ticket.get('summary').toLowerCase().replace(/^\W/, '')
      when 'openedAt'     then (ticket)-> ticket.get('openedAt')
      else throw "sorterFor doesn't know how to sort #{attribute}!"

  scoped: (filter)-> new Scheduler.Tickets(@select(filter))
