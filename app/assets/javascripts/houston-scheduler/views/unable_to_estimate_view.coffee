class Scheduler.UnableToEstimateView extends Backbone.View
  
  events:
    'click .btn-can-prioritize': 'clearUnableToPrioritize'
    'click .btn-can-estimate': 'clearUnableToEstimate'
  
  initialize: ->
    @tickets = @options.tickets
    @canEstimate = @options.canEstimate
    @canPrioritize = @options.canPrioritize
    super
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/unable_to_estimate_tickets']
    tickets = @tickets.toJSON()
    tickets = _.sortBy tickets, (ticket)-> ticket.summary
    html = template
      canEstimate: @canEstimate
      canPrioritize: @canPrioritize
      tickets: tickets
      
    $(@el).html html
    
    @$el.loadTicketDetailsOnClick()
    
    $('.table-sortable').tablesorter()
    @
  
  clearUnableToPrioritize: (e)->
    e.preventDefault()
    $ticket = $(e.target).closest('.ticket')
    @clearTicketAttribute($ticket, 'unableToSetPriority')
  
  clearUnableToEstimate: (e)->
    e.preventDefault()
    $ticket = $(e.target).closest('.ticket')
    @clearTicketAttribute($ticket, 'unableToSetEstimatedEffort')
    
  clearTicketAttribute: ($ticket, attribute)->
    $buttons = $ticket.find('button')
    id = +$ticket.attr('data-ticket-id')
    ticket = @tickets.get(id) # _.find @tickets, (ticket)-> ticket.id is id
    attributes = {}
    attributes[attribute] = null
    
    ticket.save attributes,
      patch: true
      beforeSend: =>
        $ticket.addClass 'working'
        $buttons.attr('disabled', 'disabled')
      success: =>
        $ticket.remove()
      error: =>
        console.log arguments
        $ticket.removeClass 'working'
        $buttons.removeAttr('disabled', 'disabled')
