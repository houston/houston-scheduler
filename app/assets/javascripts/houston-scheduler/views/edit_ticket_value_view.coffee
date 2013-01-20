class Scheduler.EditTicketValueView extends Scheduler.EditTicketsView
  templatePath: 'houston-scheduler/tickets/edit_value'
  
  initialize: ->
    @pageTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_value']
    super
  
  isValid: (ticket)->
    +ticket.get('estimated_value') > 0
  
