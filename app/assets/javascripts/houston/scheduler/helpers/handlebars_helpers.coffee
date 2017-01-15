Handlebars.registerHelper 'ticketEstimateBy', (ticket, maintainerId)->
  estimate = ticket["estimatedEffort[#{maintainerId}]"]
  return 'none' unless estimate
  estimate.toLowerCase()
