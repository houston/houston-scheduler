class Scheduler.EditTicketsEffortView extends Scheduler.EstimateTicketsView
  template: HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort']
  ticketsTemplate: HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort_tickets']
  taskView: Scheduler.EditTicketEffortView
  
  initialize: ->
    super
    @tickets = @incompleteTickets = @tickets.ableToEstimate().withoutEffortEstimate()
  
  ticketToJson: (ticket)->
    json = ticket.toJSON()
    json.effort = ticket.estimatedEffort()
    json.saved = ticket.estimated()
    json
