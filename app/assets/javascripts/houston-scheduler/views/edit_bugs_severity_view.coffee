class Scheduler.EditBugsSeverityView extends @TicketsView
  className: "edit-severity-view hide-completed"
  
  
  events:
    'click #show_completed_tickets': 'toggleShowCompleted'
  
  
  initialize: ->
    super
    @template = HandlebarsTemplates['houston-scheduler/tickets/edit_bugs_severity']
    @ticketsTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_bugs_severity_tickets']
    @allTickets = @tickets
    @tickets = @allTickets.withoutSeverityEstimate()
    @allTickets.on 'change', _.bind(@render, @)
  
  
  
  render: ->
    @$el.html @template()
    @$tickets = @$el.find('#tickets')
    @renderTickets()
    @
  
  renderTickets: ->
    tickets = @tickets.map (ticket)->
      json = ticket.toJSON()
      json.severity = ticket.severity()
      json.saved = !!json.severity
      json
    @$tickets.html @ticketsTemplate(tickets: tickets)
    @$tickets.find('.ticket').pseudoHover()
  
  
  toggleShowCompleted: (e)->
    $button = $(e.target)
    if $button.hasClass('active')
      $button.removeClass('btn-success')
      @tickets = @allTickets.withoutSeverityEstimate()
      @renderTickets()
    else
      $button.addClass('btn-success')
      @tickets = @allTickets
      @renderTickets()
  
  
  showTicketModal: (number)->
    App.showTicket number, null,
      tickets: @tickets
      taskView: (el, ticket, options)-> new Scheduler.EditBugSeverityView
        el: el
        ticket: ticket
        prev: options.prev
