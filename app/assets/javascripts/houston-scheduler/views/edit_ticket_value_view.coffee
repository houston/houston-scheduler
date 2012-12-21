class Scheduler.EditTicketValueView extends Scheduler.EditTicketsView
  templatePath: 'houston-scheduler/tickets/edit_value'
  
  initialize: ->
    super
  
  isValid: (ticket)->
    +ticket.get('estimated_value') > 0
  
