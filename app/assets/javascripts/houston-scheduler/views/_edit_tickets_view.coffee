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
  
  
  render: ->
    $(@el).html @pageTemplate()
    
    $list = $('#tickets').empty()
    @tickets.each (ticket)=>
      view = new Scheduler.EditTicketView
        ticket: ticket
        template: @ticketTemplate
        isValid: _.bind(@isValid, @)
      $list.appendView(view)
    @
  
  
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
