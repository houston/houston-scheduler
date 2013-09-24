class Scheduler.ShowMilestoneView extends Backbone.View
  
  events:
    'click .btn-remove': 'removeTicket'
  
  initialize: ->
    @tickets = @options.tickets
    @template = HandlebarsTemplates['houston-scheduler/milestones/show']
    super
    @render()
  
  render: ->
    tickets = (ticket.toJSON() for ticket in @tickets)
    tickets = _.sortBy tickets, (ticket)-> ticket.summary
    html = @template(tickets: tickets)
    @$el.html html
    
    $('.table-sortable').tablesorter()
    @
  
  removeTicket: (e)->
    e.preventDefault()
    
    $ticket = $(e.target).closest('.ticket')
    id = +$ticket.attr('data-ticket-id')
    ticket = _.find @tickets, (ticket)-> ticket.id is id
    
    attributes =
      milestoneId: null
    
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
