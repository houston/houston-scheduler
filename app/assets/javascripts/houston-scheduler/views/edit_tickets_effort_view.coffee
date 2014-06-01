class Scheduler.EditTicketsEffortView extends @TicketsView
  className: "edit-estimates-view hide-completed"
  
  
  events:
    'click #show_completed_tickets': 'toggleShowCompleted'
  
  
  initialize: ->
    super
    @template = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort']
    @ticketsTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort_tickets']
    @allTickets = @tickets
    @tickets = @allTickets.ableToEstimate().withoutEffortEstimate()
    @allTickets.on 'change', _.bind(@render, @)
  
  
  
  render: ->
    @$el.html @template()
    @$tickets = @$el.find('#tickets')
    @renderTickets()
    @
  
  renderTickets: ->
    tickets = @tickets.map (ticket)->
      json = ticket.toJSON()
      json.effort = ticket.estimatedEffort()
      json.saved = ticket.estimated()
      json
    @$tickets.html @ticketsTemplate(tickets: tickets)
    @$tickets.find('.ticket').pseudoHover()
  
  
  toggleShowCompleted: (e)->
    $button = $(e.target)
    if $button.hasClass('active')
      $button.removeClass('btn-success')
      @tickets = @allTickets.ableToEstimate().withoutEffortEstimate()
      @renderTickets()
    else
      $button.addClass('btn-success')
      @tickets = @allTickets
      @renderTickets()
  
  
  showTicketModal: (number)->
    App.showTicket number, null,
      tickets: @tickets
      taskView: (el, ticket, options)-> new Scheduler.EditTicketEffortView
        el: el
        ticket: ticket
        prev: options.prev
