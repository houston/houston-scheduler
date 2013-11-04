class Scheduler.UnableToEstimateView extends Backbone.View
  
  events:
    'click .btn-can-estimate': 'canEstimate'
  
  initialize: ->
    @tickets = @options.tickets
    super
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/unable_to_estimate_tickets']
    tickets = (ticket.toJSON() for ticket in @tickets)
    tickets = _.sortBy tickets, (ticket)-> ticket.summary
    html = template(tickets: tickets)
    $(@el).html html
    
    @$el.loadTicketDetailsOnClick()
    
    $('.table-sortable').tablesorter()
    @
  
  canEstimate: (e)->
    e.preventDefault()
    
    $ticket = $(e.target).closest('.ticket')
    id = +$ticket.attr('data-ticket-id')
    ticket = _.find @tickets, (ticket)-> ticket.id is id
    
    attributes =
      unableToSetEstimatedEffort: null
      unableToSetEstimatedValue: null
    
    $button = $ticket.find('button')
    $ticket.addClass 'working'
    $button.attr('disabled', 'disabled')
    ticket.save attributes,
      success: =>
        $ticket.remove()
      error: =>
        console.log arguments
        $ticket.removeClass 'working'
        $button.removeAttr('disabled', 'disabled')
