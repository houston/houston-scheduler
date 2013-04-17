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
      @$el.addClass('sequence2-ticket-cant-estimate')
    else if !ticket.estimatedEffort
      @$el.addClass('sequence2-ticket-no-effort')
    else
      height = ticket.estimatedEffort
      height = 1 if height < 1.0
      @$el.css('height', "#{height}em")
    @
