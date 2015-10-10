class Scheduler.SequenceTicketView extends Backbone.View
  tagName: 'div'
  className: 'sequence-ticket'

  initialize: ->
    @ticket = @options.ticket
    @template = HandlebarsTemplates['houston-scheduler/tickets/sequence_ticket']

  render: ->
    ticket = @ticket.toJSON()
    ticket.estimatedEffort = @ticket.estimatedEffort()
    html = @template(ticket)
    @$el.html(html)
    @$el.attr('data-ticket-id', ticket.id)
    @$el.attr('id', "ticket_#{ticket.id}")
    if ticket.resolved
      @$el.addClass('resolved disabled')
    else
      @$el.addClass('unresolved')

    if ticket.unableToSetEstimatedEffort
      @$el.addClass('sequence-ticket-cant-estimate')
    else if !@ticket.estimated()
      @$el.addClass('sequence-ticket-no-effort')
    else
      height = @ticket.estimatedEffort()
      height = 1 if height < 1.0
      @$el.attr('data-effort', height)
      @$el.css('height', "#{height}em")

    @$el.delegate '.sequence-ticket-edit', 'click', => @edit()
    @
