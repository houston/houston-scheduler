class Scheduler.SequenceTicketView extends Backbone.View
  tagName: 'div'
  className: 'sequence-ticket'
  
  initialize: ->
    @ticket = @options.ticket
    @template = HandlebarsTemplates['houston-scheduler/tickets/sequence_ticket']
  
  render: ->
    ticket = @ticket.toJSON()
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
    else if !ticket.estimatedEffort
      @$el.addClass('sequence-ticket-no-effort')
    else
      height = ticket.estimatedEffort
      height = 1 if height < 1.0
      @$el.attr('data-effort', height)
      @$el.css('height', "#{height}em")
    
    @$el.delegate '.sequence-ticket-edit', 'click', => @edit()
    @$el.bind 'edit:begin', => @edit()
    @
  
  cancelEdit: ->
    @position()
    @removeDropCloth()
    @$el.removeClass('flipped')
    window.setTimeout (=> @unposition()), 400
  
  edit: ->
    @renderEdit()
    @position()
    @$el.addClass('flipped')
    @$el.trigger('edit', @)
    @addDropCloth()
  
  removeDropCloth: ->
    $('.sequence-dropcloth').remove()
  
  addDropCloth: ->
    $dropCloth = $('<div class="sequence-dropcloth"></div>')
      .appendTo(document.body)
      .addClass('filled') # (background: 'rgba(0,0,0,0.33)')
  
  
  renderEdit: ->
    return if @$el.find('.sequence-ticket-back').length > 0
    template = HandlebarsTemplates['houston-scheduler/tickets/sequence_ticket_edit']
    html = template(@ticket.toJSON())
    @$el.find('.flippable').append html
  
  
  
  position: ->
    $flippable = @$el.find('.flippable')
    @withoutAnimation $flippable, =>
      $flippable.css
        position: 'fixed'
        top: (@$el.position().top - $(document).scrollTop()) + 'px'
        left: @$el.position().left + 'px'
        height: @$el.height() + 'px'
        width: @$el.width() + 'px'
        'z-index': 1001
  
  unposition: ->
    $flippable = @$el.find('.flippable')
    @withoutAnimation $flippable, ->
      $flippable.css
        position: ''
        top: ''
        left: ''
        height: ''
        width: ''
        'z-index': ''
  
  withoutAnimation: ($el, block)->
    $el.addClass('notransition')
    block()
    $el.height() # force reflow
    $el.removeClass('notransition')
