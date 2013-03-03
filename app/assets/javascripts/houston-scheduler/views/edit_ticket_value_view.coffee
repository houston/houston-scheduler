class Scheduler.EditTicketValueView extends Scheduler.EditTicketsView
  templatePath: 'houston-scheduler/tickets/edit_value'
  attribute: 'estimated_value'
  
  initialize: ->
    @pageTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_value']
    super
