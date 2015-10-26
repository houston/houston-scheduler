class Scheduler.EditBugsSeverityView extends Scheduler.EstimateTicketsView
  template: HandlebarsTemplates['houston/scheduler/tickets/edit_bugs_severity']
  ticketsTemplate: HandlebarsTemplates['houston/scheduler/tickets/edit_bugs_severity_tickets']
  taskView: Scheduler.EditBugSeverityView

  initialize: ->
    super
    @tickets = @incompleteTickets = @tickets.withoutSeverityEstimate()

  ticketToJson: (ticket)->
    json = ticket.toJSON()
    json.severity = ticket.severity()
    json.saved = !!json.severity
    json
