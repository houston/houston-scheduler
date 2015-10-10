class Scheduler.PostponedView extends Backbone.View

  events:
    'click .btn-unpostpone': 'canPostpone'

  initialize: ->
    @tickets = @options.tickets
    @canPrioritize = @options.canPrioritize
    super

  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/postponed_tickets']
    tickets = @tickets.toJSON()
    html = template
      canPrioritize: @canPrioritize
      tickets: tickets

    $(@el).html html

    $('.table-sortable').tablesorter
      headers:
        0: {sorter: 'sequence'}
    @

  canPostpone: (e)->
    e.preventDefault()
    $ticket = $(e.target).closest('.ticket')
    @clearTicketAttribute($ticket, 'postponed')

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
