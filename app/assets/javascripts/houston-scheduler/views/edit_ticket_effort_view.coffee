class Scheduler.EditTicketEffortView extends Scheduler.EditTicketsView
  templatePath: 'houston-scheduler/tickets/edit_effort'
  
  initialize: ->
    @pageTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort']
    super
  
  isValid: (ticket)->
    +ticket.get('estimated_effort') > 0
  
