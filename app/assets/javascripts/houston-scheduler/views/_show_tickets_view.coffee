class Scheduler.ShowTicketsView extends Backbone.View
  
  
  
  initialize: ->
    @project = @options.project
    @tickets = @options.tickets
    @readonly = @options.readonly
    @showEffort = true
    
    @$el.delegate '.sequence-ticket', 'edit', _.bind(@beginEdit, @)
    
    @__onKeyUp = _.bind(@onKeyUp, @)
    $('body').on 'keyup', @__onKeyUp
    
    @__onKeyDown = _.bind(@onKeyDown, @)
    $('body').on 'keydown', @__onKeyDown
  
  cleanup: ->
    $('body').off 'keyup', @__onKeyUp
    $('body').off 'keydown', @__onKeyDown
  
  
  
  renderShowEffortOption: ->
    $('#sequence_settings').html '''
      <label for="sequence_show_effort">
        <input type="checkbox" id="sequence_show_effort" checked="checked" />
        Show Effort
      </label>
    '''
    $('#sequence_show_effort').click (e)=>
      @showEffort = $(e.target).is(':checked')
      @showOrHideEffort()
  
  showOrHideEffort: ->
    if @showEffort
      $('.sequence-ticket').each ->
        $ticket = $(@)
        effort = $ticket.attr('data-effort')
        effort = if effort then +effort else 10
        $ticket.css('height', "#{effort}em")
    else
      $('.sequence-ticket').each ->
        $(@).css('height', '2em')
  
  
  
  onKeyUp: (e)->
    @cancelEdit() if e.keyCode == 27
  
  onKeyDown: (e)->
    if e.keyCode == 32 and @anyTicketsSelected()
      @triggerEdit()
      e.preventDefault()
  
  
  
  anyTicketsSelected: ->
    @ticketSelection().length > 0
  
  ticketSelection: ->
    $('.sequence-ticket.selected')
  
  
  
  triggerEdit: ->
    @ticketSelection().first().trigger('edit:begin')
  
  cancelEdit: ->
    @viewInEdit.cancelEdit() if @viewInEdit
    @viewInEdit = null
  
  beginEdit: (e, view)->
    @cancelEdit() if @viewInEdit isnt view
    @viewInEdit = view
