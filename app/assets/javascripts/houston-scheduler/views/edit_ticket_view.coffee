class Scheduler.EditTicketView extends Backbone.View
  tagName: 'li'
  className: 'ticket'
  
  
  events:
    'click': 'putFocusInFirstInput'
    'focus input': 'takeFocus'
    'blur input': 'loseFocus'
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
      .delegate('.ticket-details', 'click', _.bind(@showTicketDetails, @))
    @
  
  
  putFocusInFirstInput: ->
    $(@el).find('input:first').focus()
  
  
  takeFocus: ->
    $(@el).addClass('focus')
  
  loseFocus: ->
    $(@el).removeClass('focus')
  
  
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
