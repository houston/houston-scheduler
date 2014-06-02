class Scheduler.Ticket extends @Ticket
  urlRoot: '/scheduler/tickets'
  
  estimated: -> @tasks().every (task)-> +task.get('effort') > 0
  waitingForDiscussion: -> @get('unableToSetEstimatedEffort') or @get('unableToSetPriority')
  
  contributionTo: (valueStatements)->
    _.inject valueStatements
      , (sum, statement)=>
        sum + (statement.weight / 100.0) * @valueFor(statement)
      , 0
  valueEstimated: (valueStatements)->
    _.every(valueStatements, (statement)=> @valueFor(statement))
    
  valueFor: (statement)->
    value = @get("estimatedValue[#{statement.id}]")
    +(value || 0)
  
  tasks: -> @_tasks ?= new Scheduler.Tasks(@get('tasks'))
  
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
    ticket = super(ticket)
    if ticket.extendedAttributes
      ticket.sequence = +ticket.extendedAttributes['sequence']
      ticket.sequence = null if !ticket.sequence
      ticket.unableToSetEstimatedEffort = ticket.extendedAttributes['unable_to_set_estimated_effort']
      ticket.unableToSetPriority = ticket.extendedAttributes['unable_to_set_priority']
      ticket.postponed = ticket.extendedAttributes['postponed']
      
      ticket.seriousness = ticket.extendedAttributes['seriousness']
      ticket.likelihood = ticket.extendedAttributes['likelihood']
      ticket.clumsiness = ticket.extendedAttributes['clumsiness']
      
      for key, value of ticket.extendedAttributes
        if key.match(/estimated_effort\[\d+\]/)
          ticket[key.replace(/estimated_effort/, 'estimatedEffort')] = value
        if key.match(/estimated_value\[\d+\]/)
          ticket[key.replace(/estimated_value/, 'estimatedValue')] = value
    ticket



class Scheduler.Tickets extends @Tickets
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
  withValueEstimate: (valueStatements)-> @scoped (ticket)-> ticket.valueEstimated(valueStatements)
  withoutValueEstimate: (valueStatements)-> @scoped (ticket)-> !ticket.valueEstimated(valueStatements)
  ableToPrioritize: -> @scoped (ticket)-> !ticket.get('unableToSetPriority')
  ableToEstimate: -> @scoped (ticket)-> !ticket.get('unableToSetEstimatedEffort')
  waitingForDiscussion: -> @scoped (ticket)-> ticket.waitingForDiscussion()
  postponed: -> @scoped (ticket)-> !!ticket.get('postponed')
  unpostponed: -> @scoped (ticket)-> !ticket.get('postponed')
  
  sorterFor: (attribute)->
    switch attribute
      when 'sequence'     then (ticket)-> +ticket.get('sequence')
      else                super(attribute)

  scoped: (filter)-> new Scheduler.Tickets(@select(filter))
