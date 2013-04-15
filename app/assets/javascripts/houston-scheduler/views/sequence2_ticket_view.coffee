class Scheduler.Sequence2TicketView extends Backbone.View
  tagName: 'li'
  className: 'sequence2-ticket'
  
  initialize: ->
    @ticket = @options.ticket
    @template = HandlebarsTemplates['houston-scheduler/tickets/sequence2_ticket']
  
  render: ->
    ticket = @ticket.toJSON()
    html = @template(ticket)
    @$el.html(html)
    @$el.attr('data-ticket-id', ticket.id)
    
    if ticket.unableToSetEstimatedEffort
      @$el.addClass('sequence2-ticket-cant-estimate').popover
        placement: 'top'
        trigger: 'hover'
        title: 'Unable to Estimate'
        content: 'As it is, we can\'t give an estimate for this ticket. More detail or incubation is needed.'
    else if !ticket.estimatedEffort
      @$el.addClass('sequence2-ticket-no-effort').popover
        placement: 'top'
        trigger: 'hover'
        title: 'No Estimate'
        content: 'We haven\'t estimated this ticket yet. Its size is not an indicator of how long it will take.'
    else
      @$el.css('height', "#{ticket.estimatedEffort}em")
    @
