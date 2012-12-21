class Scheduler.TicketView extends Backbone.View
  tagName: 'li'
  className: 'task'
  
  # events:
  #   'keyup input': 'updateTicket'
  # 
  initialize: ->
    @ticket = @options.ticket
    @ticket.bind 'change', _.bind(@render, @)
  
  render: ->
    $el = $(@el)
    template = HandlebarsTemplates['houston-scheduler/tickets/show']
    $el.html template(@ticket.toJSON())
    $el.attr('data-cid', @ticket.cid)
    $el.find('[rel=tooltip]').tooltip()
    # @renderPriority()
    @
  
  # updateTicket: ->
  #   $el = $(@el)
  #   
  #   attributes = $el.serializeFormElements()
  #   @ticket.set attributes, {silent: true}
  #   
  #   @renderPriority()
  # 
  # renderPriority: ->
  #   $el = $(@el)
  #   $el.find('.ticket-priority .output').html @ticket.priority().toFixed(0)
  #   $el.attr('data-priority', @ticket.priority())
