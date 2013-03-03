class Scheduler.EditTicketEffortView extends Scheduler.EditTicketsView
  templatePath: 'houston-scheduler/tickets/edit_effort'
  attribute: 'estimated_effort'
  
  initialize: ->
    @pageTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort']
    super
