class Scheduler.EditTicketEffortView extends Scheduler.EditTicketsView
  templatePath: 'houston-scheduler/tickets/edit_effort'
  attribute: 'estimatedEffort'
  
  initialize: ->
    @pageTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort']
    super
