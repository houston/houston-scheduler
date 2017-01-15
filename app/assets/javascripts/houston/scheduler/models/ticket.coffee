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
    if ticket.props
      ticket.sequence = +ticket.props['scheduler.sequence']
      ticket.sequence = null if !ticket.sequence
      ticket.unableToSetEstimatedEffort = ticket.props['scheduler.unableToSetEstimatedEffort']
      ticket.unableToSetPriority = ticket.props['scheduler.unableToSetPriority']
      ticket.postponed = ticket.props['scheduler.postponed']

      ticket.seriousness = ticket.props['scheduler.seriousness']
      ticket.likelihood = ticket.props['scheduler.likelihood']
      ticket.clumsiness = ticket.props['scheduler.clumsiness']

      for key, value of ticket.props
        if key.match(/scheduler\.estimated(Effort|Value)\.\d+/)
          ticket[key.replace(/\.(\d+)$/, '[$1]')] = value
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
  unsorted: -> @withoutSequence()
  withoutSequence: -> @select (ticket)-> !ticket.get('sequence')
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
