KEYS = {
  13: "RETURN",
  27: "ESC",
  38: "UP",
  40: "DOWN"
}

class Scheduler.EditTicketsView extends Backbone.View
  className: "edit-estimates-view hide-completed"
  
  
  events:
    'keydown input': 'onKeyDown'
    'click #show_completed_tickets': 'toggleShowCompleted'
  
  
  keyDownHandlers:
    UP:     -> @putFocusOn @prevLine()
    DOWN:   -> @putFocusOn @nextLine()
  
  
  initialize: ->
    @ticketTemplate = HandlebarsTemplates[@templatePath]
    @tickets = @options.tickets
  
  
  render: ->
    $(@el).html @pageTemplate()
    
    # Allow scrolling with mousewheel rather than
    # spinning a ticket's effort estimate up or down
    @$el.delegate 'input[type="number"]', 'mousewheel', -> $(@).blur()
    @$el.delegate '.ticket', 'click', -> $(@).find('input:first').focus()
    @$el.delegate 'input', 'focus', -> $(@).closest('.ticket').addClass('focus')
    @$el.delegate 'input', 'blur', -> $(@).closest('.ticket').removeClass('focus')
    
    $list = $('#tickets').empty()
    @tickets.each (ticket)=>
      view = new Scheduler.EditTicketView
        ticket: ticket
        template: @ticketTemplate
        isValid: _.bind(@isValid, @)
        attribute: @attribute
      $list.appendView(view)
    
    @$el.loadTicketDetailsOnClick()
    
    $('.table-sortable').tablesorter
      headers:
        0: {sorter: 'sequence'}
        1: {sorter: 'inputs'}
    @
  
  
  isValid: (ticket)->
    +ticket.get(@attribute) > 0
  
  
  onKeyDown: (e)->
      keyName = @identifyKey(e.keyCode)
      handler = @keyDownHandlers[keyName]
      if handler
        e.preventDefault()
        handler.apply(@)
  
  identifyKey: (code)->
      KEYS[code]
  
  
  putFocusOn: ($line)->
    $line.find('input:first').focus()
  
  prevLine: ->
    $prev = @thisLine().prev()
    $prev = $prev.prev() while $prev.is('.unable-to-estimate, .saved-on-render')
    $prev
    
  nextLine: ->
    $next = @thisLine().next()
    $next = $next.next() while $next.is('.unable-to-estimate, .saved-on-render')
    $next
    
  thisLine: ->
    $('input:focus').closest('.ticket')
  
  
  
  toggleShowCompleted: (e)->
    $button = $(e.target)
    if $button.hasClass('active')
      $button.removeClass('btn-success')
      @$el.addClass('hide-completed')
    else
      $button.addClass('btn-success')
      @$el.removeClass('hide-completed')
  
