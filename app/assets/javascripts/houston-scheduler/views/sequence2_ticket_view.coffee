class Scheduler.Sequence2TicketView extends Backbone.View
  tagName: 'div'
  className: 'sequence2-ticket'
  
  initialize: ->
    @ticket = @options.ticket
    @template = HandlebarsTemplates['houston-scheduler/tickets/sequence2_ticket']
  
  render: ->
    ticket = @ticket.toJSON()
    ticket.noEstimate = !ticket.unableToSetEstimatedEffort && !ticket.estimatedEffort
    html = @template(ticket)
    @$el.html(html)
    @$el.attr('data-ticket-id', ticket.id)
        .delegate('.ticket-details', 'click', _.bind(@showTicketDetails, @))
    
    if ticket.unableToSetEstimatedEffort
      @$el.addClass('sequence2-ticket-cant-estimate')
    else if !ticket.estimatedEffort
      @$el.addClass('sequence2-ticket-no-effort')
    else
      height = ticket.estimatedEffort
      height = 1 if height < 1.0
      @$el.attr('data-effort', height)
      @$el.css('height', "#{height}em")
    @

  showTicketDetails: (e)->
    e.preventDefault()
    e.stopImmediatePropagation()
    url = $(e.target).attr('href')
    $.get url, (ticket)->
      html = """
      <div class="modal hide fade">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3>Description</h3>
        </div>
        <div class="modal-body">
          #{ticket.description}
        </div>
      </div>
      """
      $(html).modal()