class Scheduler.ScheduleView extends Backbone.View
  
  events:
    'click #sort_tickets': 'sortByPriority'
    'change #queuing_discipline': 'changeQueuingDiscipline'
    'change #resources_count': 'updateWipConstraint'
  
  initialize: ->
    @tickets = @options.tickets
    @queuingDiscipline = new Scheduler.QueuingDiscipline.MaximizeRoi()
    @wip = 3
  
  sortedTickets: ->
    _.sortBy(@tickets, @queuingDiscipline.sorter)
  
  changeQueuingDiscipline: ->
    disciplineName = $('#queuing_discipline').val()
    @queuingDiscipline = _.find Scheduler.QueuingDisciplines, (discipline)->
      discipline.name == disciplineName
    @sortByPriority()
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/index']
    html = template
      queuingDisciplines: Scheduler.QueuingDisciplines
    $(@el).html(html)
    
    @renderTickets()
    @renderSchedule()
    @
  
  renderTickets: ->
    $ul = $('#tickets')
    $ul.empty()
    for ticket in @sortedTickets()
      $ul.appendView(new Scheduler.TicketView(ticket: ticket))
  
  renderSchedule: ->
    $schedule = $('#schedule')
    $schedule.empty()
    
    @tickets.each (ticket)->
      # color = projects[ticket.get('project')]
      color = '#39b3aa'
      $schedule.append "<div class=\"scheduled-task\" data-cid=\"#{ticket.cid}\" style=\"background-color: #{color}\"></div>"
    
    @updateSchedule()
  
  
  
  updateWipConstraint: ->
    @wip = +$('#resources_count').val()
    @updateSchedule()
  
  updateSchedule: ->
    tickets = @sortedTickets()
    numberOfRows = @wip
    rows = (new Row(i) for i in [1..numberOfRows])
    
    positionByCID = {}
    for ticket in tickets
      shortestRow = _.min rows, (row)-> row.width()
      positionByCID[ticket.cid] =
        width: +ticket.get('estimated_effort')
        y: shortestRow.index
        x: shortestRow.width()
      shortestRow.addTicket(ticket)
    
    maxWidth = (_.max rows, (row)-> row.width()).width()
    
    $('#schedule_axis').html("#{maxWidth} hours")
    
    # $.clear()
    
    $('#schedule').tween
      height: 
        stop: @wip * 22
        duration: 0.50
        effect: 'quadInOut'
    
    for cid, position of positionByCID
      widthPercent = position.width / maxWidth * 100
      leftPercent = position.x / maxWidth * 100
      top = (position.y - 1) * 22
      
      $(".scheduled-task[data-cid=#{cid}]").tween
        left:
          stop: "#{leftPercent}%"
          duration: 0.50
          effect: 'quadInOut'
        width:
          stop: "#{widthPercent}%"
          duration: 0.50
          effect: 'quadInOut'
        top:
          stop: top
          duration: 0.50
          effect: 'quadInOut'
    
    $.play()
  
  
  sortByPriority: ->
    sortedTickets = @sortedTickets()
    
    positionByCID = {}
    for pos in [0...sortedTickets.length]
      ticket = sortedTickets[pos]
      positionByCID[ticket.cid] = pos
    
    @animateTicketsToPositions
      duration: 0.50
      easing: 'quadInOut'
      positionByCID: positionByCID
      onComplete: _.bind(@renderTickets, @)
  
  animateTicketsToPositions: (options)->
    duration      = options.duration
    easing        = options.easing
    positionByCID = options.positionByCID
    onComplete    = options.onComplete
    
    $el = $(@el)
    $tickets = $el.find('.task')
    ticketHeight = 38
    
    $('#tickets').css(height: $('#tickets').height())
    $tickets.positionAbsolutely()
    
    $.clear()
    
    for pos in [0...$tickets.length]
      $ticket = $($tickets[pos])
      
      cid = $ticket.attr('data-cid')
      newPosition = positionByCID[cid]
      
      unless pos == newPosition
        newTop = newPosition * ticketHeight
        params = 
          top:
            start: $ticket.position().top
            stop: newTop
            duration: duration
            effect: easing
        $ticket.tween(params)
    
    $.play =>
      $('#tickets').css(height: '')
      @updateSchedule()
      onComplete()


class Row
  
  constructor: (index)->
    @index = index
    @tickets = []
  
  addTicket: (ticket)->
    @tickets.push ticket
  
  width: ->
    _.reduce @tickets, ((sum, ticket)-> sum + +ticket.get('estimated_effort')), 0

