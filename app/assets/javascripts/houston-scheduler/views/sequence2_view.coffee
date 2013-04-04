class Scheduler.Sequence2View extends Backbone.View
  
  events:
    'click .sequence2-ticket': 'toggleLock'
    'click .sequence2-moveup': 'moveUp'
    'click .sequence2-movedown': 'moveDown'
  
  initialize: ->
    @tickets = @options.tickets
    @sortedTickets = @tickets.toArray().slice(0, 5)
    @unsortedTickets = @tickets.toArray().slice(5)
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/sequence2']
    html = template()
    @$el.html(html)
    
    $unsortedTickets = @$el.find('#sequence2_unsorted')
    $sortedTickets = @$el.find('#sequence2_sorted')
    
    $unsortedTickets.appendView(new Scheduler.Sequence2TicketView(ticket: ticket)) for ticket in @unsortedTickets
    $sortedTickets.appendView(new Scheduler.Sequence2TicketView(ticket: ticket)) for ticket in @sortedTickets
    
    @$el.find('li').pseudoHover()
    @$el.find('.sequence2-list').sortable
      connectWith: '.sequence2-list'
    @
  
  toggleLock: (e)->
    $ticket = $(e.target).closest('.sequence2-ticket')
    $('.sequence2-locked').not($ticket).removeClass('sequence2-locked')
    $ticket.toggleClass('sequence2-locked')
  
  moveUp: (e)->
    e.preventDefault()
    e.stopImmediatePropagation()
    $ticket = $(e.target).closest('.sequence2-ticket')
    $prev = $ticket.prev()
    $ticket.remove().insertBefore($prev).pseudoHover() if $prev.length > 0

  moveDown: (e)->
    e.preventDefault()
    e.stopImmediatePropagation()
    $ticket = $(e.target).closest('.sequence2-ticket')
    $next = $ticket.next()
    $ticket.remove().insertAfter($next).pseudoHover() if $next.length > 0
    