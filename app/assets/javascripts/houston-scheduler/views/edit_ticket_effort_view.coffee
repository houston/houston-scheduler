class Scheduler.EditTicketEffortView extends Scheduler.EditTicketsView
  templatePath: 'houston-scheduler/tickets/edit_effort'
  attribute: 'estimatedEffort'
  
  initialize: ->
    @pageTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort']
    super
  
  onKeyPress: (e)->
    character = String.fromCharCode(e.charCode)
    value = $(e.target).val() + character
    e.preventDefault() unless /[\d\.]+/.test(value)
    
    if character == 'm'
      $ticket = $('.ticket.focus')
      Scheduler.loadTicketDetails $ticket.find('a.ticket-details').attr('href'), ->
        $ticket.find('input').focus()
