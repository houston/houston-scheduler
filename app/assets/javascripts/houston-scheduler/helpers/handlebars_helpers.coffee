Handlebars.registerHelper 'ticketEstimateBy', (ticket, maintainerId)->
  estimate = ticket["estimatedEffort[#{maintainerId}]"]
  return 'none' unless estimate
  estimate.toLowerCase()

Handlebars.registerPartial 'sprintTicket', (ticket)->
  HandlebarsTemplates['houston-scheduler/sprints/ticket'](ticket)

Handlebars.registerHelper 'formatPrerequisites', (prerequisites)->
  tickets = Scheduler.tickets.numbered(prerequisites)
  return '' unless tickets.length
  
  links = for ticket in tickets
    "<a href=\"#{ticket.get('ticketUrl')}\" target=\"_blank\" rel=\"tooltip\" data-tooltip-placement=\"right\" data-original-title=\"View in #{ticket.get('ticketSystem')}\">##{ticket.get('number')}</a>"
  
  "<span class=\"ticket-prerequisites label\">Requires: #{links.join(", ")}</span>"
