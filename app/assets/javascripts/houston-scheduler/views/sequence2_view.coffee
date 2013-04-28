class Scheduler.Sequence2View extends Backbone.View
  
  
  initialize: ->
    @project = @options.project
    @tickets = @options.tickets
    @readonly = @options.readonly
    
    # To cut down on network traffic, send the 
    # send the sort order 800ms after the user has
    # stopped making changes to it.
    #
    @delayedNotifier = new Lail.DelayedAction(_.bind(@updateOrder, @), delay: 800)
    
    $('body').click (e)->
      if $(e.target).closest('.sequence2-list').length == 0
        $('.sequence2-list .selected').removeClass('selected')
    
    @sortedTickets = @tickets.sorted()
    @unsortedTickets = @tickets.unsorted()
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/sequence2']
    html = template
      projectName: @project.name
    @$el.html(html)
    
    $unsortedTickets = @$el.find('#sequence2_unsorted')
    $sortedTickets = @$el.find('#sequence2_sorted')
    
    @$el.find('.sequence2-explanation').popover()
    
    $unsortedTickets.appendView(new Scheduler.Sequence2TicketView(ticket: ticket)) for ticket in @unsortedTickets
    $sortedTickets.appendView(new Scheduler.Sequence2TicketView(ticket: ticket)) for ticket in @sortedTickets
    
    @$el.find('.sequence2-ticket').pseudoHover()
    
    unless @readonly
      view = @
      @$el.find('.sequence2-list').multisortable
        connectWith: '.sequence2-list'
        activate: (event, ui)-> $(@).addClass('sort-active')
        deactivate: (event, ui)-> $(@).removeClass('sort-active')
        
        # unselect items in the opposite list
        click: (event, e)->
          $('.sequence2-list').not(e.parent()).find('.selected').removeClass('selected')
      
      @$el.find('#sequence2_sorted').on 'sortupdate', (event, ui)=>
        @delayedNotifier.trigger()
    @
  
  updateOrder: ->
    $tickets = $('#sequence2_sorted .sequence2-ticket')
    ids = _.map $tickets, (el)-> $(el).attr('data-ticket-id')
    ids = "empty" if $tickets.length == 0
    url = window.location.pathname + '/ticket_order'
    $.put url, {order: ids}
    
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
    