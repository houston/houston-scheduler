KEYS = {
  13: "RETURN",
  27: "ESC",
  38: "UP",
  40: "DOWN"
}

class Scheduler.EditTicketsView extends Backbone.View
  className: "edit-estimates-view"
  
  
  events:
    'keydown input': 'onKeyDown'
  
  
  keyDownHandlers:
    UP:     -> @putFocusOn @prevLine()
    DOWN:   -> @putFocusOn @nextLine()
  
  
  initialize: ->
    @ticketTemplate = HandlebarsTemplates[@templatePath]
    @tickets = @options.tickets
    
    $.tablesorter.addParser
      id: 'inputs'
      is: (s)-> false # don't auto-detect
      format: (text, table, td)->
        $(td).find('input').val()
      type: 'numeric'
  
  
  render: ->
    $(@el).html @pageTemplate()
    
    # Allow scrolling with mousewheel rather than
    # spinning a ticket's effort estimate up or down
    $(@el).delegate 'input[type="number"]', 'mousewheel', -> $(@).blur()
    
    $list = $('#tickets').empty()
    @tickets
      .sortBy (ticket)=>
        (+ticket.get('estimatedEffort') > 0) * 99999999 + # put tickets _with_ estimates at the bottom,
        (+ticket.get('sequence') <= 0) * 9999999 +        # then tickets with no priority,
         +ticket.get('sequence')                          # finally sort by priority
      .each (ticket)=>
        view = new Scheduler.EditTicketView
          ticket: ticket
          template: @ticketTemplate
          isValid: _.bind(@isValid, @)
          attribute: @attribute
        $list.appendView(view)
    
    $('.table-sortable').tablesorter
      headers: {0: {sorter: 'inputs'}}
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
    @thisLine().prev()
    
  nextLine: ->
    @thisLine().next()
    
  thisLine: ->
    $('input:focus').closest('.ticket')

