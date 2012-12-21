class Scheduler.EditTicketEffortView extends Scheduler.EditTicketsView
  templatePath: 'houston-scheduler/tickets/edit_effort'
  
  initialize: ->
    super
  
  isValid: (ticket)->
    +ticket.get('estimated_effort') > 0
  
