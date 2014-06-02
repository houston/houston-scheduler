class Scheduler.EstimateTicketsView extends @TicketsView
  className: 'edit-estimates-view hide-completed'
  
  events:
    'click #show_completed_tickets': 'toggleShowCompleted'
  
  initialize: ->
    super
    @allTickets = @incompleteTickets = @tickets
    @tickets.on 'change', _.bind(@render, @)
  
  render: ->
    @$el.html @template()
    @$tickets = @$el.find('#tickets')
    @renderTickets()
    @
  
  renderTickets: ->
    tickets = @tickets.map(_.bind(@ticketToJson, @))
    @$tickets.html @ticketsTemplate(tickets: tickets)
    @$tickets.find('.ticket').pseudoHover()
  
  ticketToJson: (ticket)->
    json = ticket.toJSON()
  
  toggleShowCompleted: (e)->
    $button = $(e.target)
    if $button.hasClass('active')
      $button.removeClass('btn-success')
      @tickets = @incompleteTickets
      @renderTickets()
    else
      $button.addClass('btn-success')
      @tickets = @allTickets
      @renderTickets()
  
  showTicketModal: (number)->
    tickets: @tickets
    taskView: (el, ticket, options)=> new @taskView
      el: el
      ticket: ticket
      prev: options.prev
      project: @project
