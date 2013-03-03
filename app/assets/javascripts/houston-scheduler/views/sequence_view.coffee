class Scheduler.SequenceView extends Backbone.View
  
  events:
    'click #sort_tickets': 'sortByPriority'
    'change #queuing_discipline': 'changeQueuingDiscipline'
  
  initialize: ->
    @tickets = @options.tickets
    @queuingDiscipline = new Scheduler.QueuingDiscipline.MaximizeRoi()
  
  sortedTickets: ->
    _.sortBy(@tickets, @queuingDiscipline.sorter)
  
  changeQueuingDiscipline: ->
    disciplineName = $('#queuing_discipline').val()
    @queuingDiscipline = _.find Scheduler.QueuingDisciplines, (discipline)->
      discipline.name == disciplineName
    @sortByPriority()
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/sequence']
    html = template
      queuingDisciplines: Scheduler.QueuingDisciplines
    $(@el).html(html)
    
    @renderTickets()
    @
  
  renderTickets: ->
    $ul = $('#tickets')
    $ul.empty()
    for ticket in @sortedTickets()
      $ul.appendView(new Scheduler.TicketView(ticket: ticket))
  
  
  
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
    $tickets = $el.find('.ticket')
    ticketHeight = 24
    
    $('#tickets').css(height: $('#tickets').height()).removeClass('with-stripes')
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
      $('#tickets').css(height: '').addClass('with-stripes')
      onComplete()
