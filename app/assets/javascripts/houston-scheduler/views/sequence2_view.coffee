class Scheduler.Sequence2View extends Backbone.View
  
  events:
    'click .sequence2-ticket': 'toggleLock'
    'click .sequence2-moveup': 'moveUp'
    'click .sequence2-movedown': 'moveDown'
  
  initialize: ->
    @tickets = @options.tickets
    @readonly = @options.readonly
    
    @sortedTickets = @tickets.sorted()
    @unsortedTickets = @tickets.unsorted()
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/sequence2']
    html = template()
    @$el.html(html)
    
    $unsortedTickets = @$el.find('#sequence2_unsorted')
    $sortedTickets = @$el.find('#sequence2_sorted')
    
    $unsortedTickets.appendView(new Scheduler.Sequence2TicketView(ticket: ticket)) for ticket in @unsortedTickets
    $sortedTickets.appendView(new Scheduler.Sequence2TicketView(ticket: ticket)) for ticket in @sortedTickets
    
    unless @readonly
      view = @
      @$el.find('li').pseudoHover()
      @$el.find('.sequence2-list').sortable
        connectWith: '.sequence2-list'
        activate: (event, ui)-> $(@).addClass('sort-active')
        deactivate: (event, ui)-> $(@).removeClass('sort-active')
      
      @$el.find('#sequence2_sorted').on 'sortupdate', (event, ui)->
        id = ui.item.attr('data-ticket-id')
        ticket = view.tickets.get(id)
        sorted = ui.item.closest('#sequence2_sorted').length > 0
        index = if sorted then ui.item.index() + 1 else null
        
        if sorted
          console.log "ticket ##{id} was move to position #{index}"
        else
          console.log "ticket ##{id} was moved to the backlog"
        
        ui.item.addClass('working')
        ticket.save {sequence: index},
          success: =>
            ui.item.removeClass('working')
          error: =>
            console.log arguments
            ui.item.removeClass('working')
          complete: =>
            ui.item.removeClass('working')
    @
  
  toggleLock: (e)->
    return if @readonly
    
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
    