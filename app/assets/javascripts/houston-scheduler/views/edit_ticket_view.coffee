class Scheduler.EditTicketView extends Backbone.View
  tagName: 'li'
  className: 'ticket'
  
  
  events:
    'click': 'putFocusInFirstInput'
    'change input': 'saveValue'
  
  
  initialize: ->
    @ticket = @options.ticket
    @template = @options.template
    @isValid = @options.isValid
    $(@el).cssHover()
  
  render: ->
    $(@el)
      .attr('id', "ticket_#{@ticket.get('id')}")
      .html(@template @ticket.toJSON())
    @
  
  putFocusInFirstInput: ->
    $(@el).find('input:first').focus()
  
  saveValue: ->
    attributes = $(@el).serializeFormElements()
    $(@el).addClass 'working'
    @ticket.save attributes,
      success: =>
        $(@el)
          .removeClass('working')
          .toggleClass('saved', @isValid(@ticket))
      error: =>
        console.log arguments
        $(@el).removeClass 'working'
      complete: =>
        $(@el).removeClass 'working'
