class Scheduler.ShowTicketsView extends Backbone.View
  
  
  
  initialize: ->
    @project = @options.project
    @tickets = @options.tickets
    @readonly = @options.readonly
    @showEffort = true
    
    # Unselect tickets when clicking away from the lists
    $('body').click (e)->
      if $(e.target).closest('.sequence-list').length == 0
        $('.sequence-list .selected').removeClass('selected')
    
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
  
  
  
  makeTicketsSortable: (options={})->
    view = @
    
    if options.connected
      options = _.extend options,
        connectWith: '.sequence-list'
        cancel: '.disabled'
        
        # unselect items in the opposite list
        start: (event, ui)->
          $e = ui.item
          $('.sequence-list').not($e.parent())
            .find('.selected, .multiselectable-previous')
            .removeClass('selected multiselectable-previous')
        
        click: (event, $e)->
          return unless $e.is('.sequence-ticket')
          $('.sequence-list').not($e.parent())
            .find('.selected, .multiselectable-previous')
            .removeClass('selected multiselectable-previous')
    
    @$el.find('.sequence-list').multisortable _.extend(options,
      containment: '#houston_scheduler_view'
      activate: (event, ui)-> $(@).addClass('sort-active').parent().addClass('sort-active')
      deactivate: (event, ui)-> $(@).removeClass('sort-active').parent().removeClass('sort-active')
    )
  
  
  
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
