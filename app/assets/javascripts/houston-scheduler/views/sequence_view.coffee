class Scheduler.SequenceView extends Backbone.View
  
  
  
  initialize: ->
    @project = @options.project
    @tickets = @options.tickets
    @readonly = @options.readonly
    @velocity = @options.velocity
    @showEffort = true
    
    # To cut down on network traffic, send the 
    # send the sort order 800ms after the user has
    # stopped making changes to it.
    #
    @delayedNotifier = new Lail.DelayedAction(_.bind(@updateOrder, @), delay: 800)
    
    $('body').click (e)->
      if $(e.target).closest('.sequence-list').length == 0
        $('.sequence-list .selected').removeClass('selected')
    
    @__onKeyUp = _.bind(@onKeyUp, @)
    $('body').on 'keyup', @__onKeyUp
    
    @__onKeyDown = _.bind(@onKeyDown, @)
    $('body').on 'keydown', @__onKeyDown
    
    @sortedTickets = @tickets.sorted()
    @unsortedTickets = @tickets.unsorted()
  
  cleanup: ->
    $('body').off 'keyup', @__onKeyUp
    $('body').off 'keydown', @__onKeyDown
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/sequence']
    html = template
      projectName: @project.name
      velocity: @velocity
      showInstuctions: !@readonly
    @$el.html(html)
    
    @newTicketView = new Scheduler.NewTicketView
      project: @project
      el: $('#new_ticket_form')[0]
    @newTicketView.render()
    @newTicketView.bind 'create', (ticket)=>
      $ticket = @prependTicketTo ticket, @$el.find('#sequence_unsorted')
      $ticket.pseudoHover()
    
    $('#sequence_settings').html '''
      <label for="sequence_show_effort">
        <input type="checkbox" id="sequence_show_effort" checked="checked" />
        Show Effort
      </label>
    '''
    $('#sequence_show_effort').click (e)=>
      @showEffort = $(e.target).is(':checked')
      @showOrHideEffort()
    
    $unsortedTickets = @$el.find('#sequence_unsorted')
    $sortedTickets = @$el.find('#sequence_sorted')
    
    @$el.find('.sequence-explanation').popover()
    
    $unsortedTickets.appendView(new Scheduler.SequenceTicketView(ticket: ticket)) for ticket in @unsortedTickets
    $sortedTickets.appendView(new Scheduler.SequenceTicketView(ticket: ticket)) for ticket in @sortedTickets
    
    @$el.delegate '.sequence-ticket', 'edit', _.bind(@beginEdit, @)
    
    @$el.find('.sequence-ticket').pseudoHover()
    
    unless @readonly
      view = @
      @$el.find('.sequence-list').multisortable
        connectWith: '.sequence-list'
        activate: (event, ui)-> $(@).addClass('sort-active')
        deactivate: (event, ui)-> $(@).removeClass('sort-active')
        
        start: (event, ui)->
          $e = ui.item
          $('.sequence-list').not($e.parent())
            .find('.selected, .multiselectable-previous')
            .removeClass('selected multiselectable-previous')
        
        receive: (event, ui)=>
          if ui.item.closest('#sequence_unsorted').length > 0
            @clearSequenceOfTicketFor(ui.item)
            @delayedNotifier.trigger()
            @adjustVelocityIndicatorHeight()
        
        # unselect items in the opposite list
        click: (event, $e)->
          return unless $e.is('.sequence-ticket')
          $('.sequence-list').not($e.parent())
            .find('.selected, .multiselectable-previous')
            .removeClass('selected multiselectable-previous')
      
      @$el.find('#sequence_sorted').on 'sortupdate', (event, ui)=>
        @delayedNotifier.trigger()
        @adjustVelocityIndicatorHeight()
    
    @adjustVelocityIndicatorHeight()
    
    $indicator = $('#sequence_velocity_help')
    $indicator.popover
      placement: 'left'
      trigger: 'hover'
      title: 'Velocity'
      content: 'This bar indicates this project\'s velocity. Any tickets that fit within its height should fit within one week of development.'
    
    @
  
  
  
  clearSequenceOfTicketFor: ($el)->
    id = $el.attr('data-ticket-id')
    @setTicketSequence(id, null)
  
  setTicketSequence: (id, value)->
    return console.log("id was undefined") unless id
    ticket = @tickets.get(id)
    return console.log("ticket #{id} was not found") unless ticket
    ticket.set('sequence': value)
  
  
  
  updateOrder: ->
    $tickets = $('#sequence_sorted .sequence-ticket')
    ids = _.map $tickets, (el)-> $(el).attr('data-ticket-id')
    @setTicketSequence(ids[i], i + 1) for i in [0...ids.length]
    ids = "empty" if $tickets.length == 0
    url = window.location.pathname + '/ticket_order'
    $.put url, {order: ids}
  
  
  
  onKeyUp: (e)->
    if e.shiftKey
      @moveLeft() if e.keyCode == 37
      @moveUp() if e.keyCode == 38
      @moveRight() if e.keyCode == 39
      @moveDown() if e.keyCode == 40
    else
      @cancelEdit() if e.keyCode == 27
      @moveSelectionLeft() if e.keyCode == 37
      @moveSelectionUp() if e.keyCode == 38
      @moveSelectionRight() if e.keyCode == 39
      @moveSelectionDown() if e.keyCode == 40
  
  onKeyDown: (e)->
    if e.keyCode == 32 and @anyTicketsSelected()
      @triggerEdit()
      e.preventDefault()
  
  
  
  anyTicketsSelected: ->
    @ticketSelection().length > 0
  
  ticketSelection: ->
    $('.sequence-ticket.selected')
  
  
  
  moveLeft: ->
    $ticket = $('#sequence_sorted .sequence-ticket.selected')
    if $ticket.length > 0
      index = $ticket.index()
      $target = $("#sequence_unsorted .sequence-ticket:eq(#{index})")
      if $target.length == 0
        $ticket = $ticket.remove().appendTo('#sequence_unsorted').data('multiselectable', true).pseudoHover()
      else
        $ticket = $ticket.remove().insertBefore($target).data('multiselectable', true).pseudoHover()
      
      @clearSequenceOfTicketFor($ticket)
      @delayedNotifier.trigger()
      @adjustVelocityIndicatorHeight()
  
  moveUp: ->
    $ticket = $('.sequence-ticket.selected')
    $prev = $ticket.prev()
    if $prev.length > 0
      $ticket.remove().insertBefore($prev).data('multiselectable', true).pseudoHover()
      
      @delayedNotifier.trigger()
      @adjustVelocityIndicatorHeight()
  
  moveRight: ->
    $ticket = $('#sequence_unsorted .sequence-ticket.selected')
    if $ticket.length > 0
      index = $ticket.index()
      $target = $("#sequence_sorted .sequence-ticket:eq(#{index})")
      if $target.length == 0
        $ticket.remove().appendTo('#sequence_sorted').data('multiselectable', true).pseudoHover()
      else
        $ticket.remove().insertBefore($target).data('multiselectable', true).pseudoHover()
      
      @delayedNotifier.trigger()
      @adjustVelocityIndicatorHeight()
  
  moveDown: ->
    $ticket = $('.sequence-ticket.selected')
    $next = $ticket.next()
    if $next.length > 0
      $ticket.remove().insertAfter($next).data('multiselectable', true).pseudoHover()
      
      @delayedNotifier.trigger()
      @adjustVelocityIndicatorHeight()
  
  
  
  moveSelectionLeft: ->
    $ticket = $('#sequence_sorted .sequence-ticket.selected')
    if $ticket.length > 0
      index = $ticket.index()
      $target = $("#sequence_unsorted .sequence-ticket:eq(#{index})")
      $target = $("#sequence_unsorted .sequence-ticket:last") if $target.length == 0
      if $target.length > 0
        $('.multiselectable-previous').removeClass('multiselectable-previous')
        $ticket.removeClass('selected')
        $target.addClass('selected multiselectable-previous')
  
  moveSelectionUp: ->
    $ticket = $('.sequence-ticket.selected')
    $prev = $ticket.prev()
    if $prev.length > 0
      $('.multiselectable-previous').removeClass('multiselectable-previous')
      $ticket.removeClass('selected')
      $prev.addClass('selected multiselectable-previous')
  
  moveSelectionRight: ->
    $ticket = $('#sequence_unsorted .sequence-ticket.selected')
    if $ticket.length > 0
      index = $ticket.index()
      $target = $("#sequence_sorted .sequence-ticket:eq(#{index})")
      $target = $("#sequence_sorted .sequence-ticket:last") if $target.length == 0
      if $target.length > 0
        $('.multiselectable-previous').removeClass('multiselectable-previous')
        $ticket.removeClass('selected')
        $target.addClass('selected multiselectable-previous')
  
  moveSelectionDown: ->
    $ticket = $('.sequence-ticket.selected')
    $next = $ticket.next()
    if $next.length > 0
      $('.multiselectable-previous').removeClass('multiselectable-previous')
      $ticket.removeClass('selected')
      $next.addClass('selected multiselectable-previous')
  
  
  
  adjustVelocityIndicatorHeight: ->
    # The height of the velocity indicator is {{points}em just like the height of tickets;
    # but tickets have borders and padding and margins and those skew the perspective.
    # 
    # So we'll add that padding into the height of the velocity indicator: 0.75em for every
    # ticket that can be begun this week and another 0.75em of every ticket that can be
    # complete.
    
    velocity = @velocity
    totalEffort = 0
    totalPadding = if velocity > 0 then 0.75 else 0
    ticketsThatFit = 0
    $('#sequence_sorted .sequence-ticket').each (i)->
      effort = $(@).attr('data-effort')
      effort = if effort then +effort else 10
      totalEffort += effort
      return false if totalEffort >= velocity
      totalPadding += 1.5
      ticketsThatFit += 1
    
    if @showEffort
      $('#sequence_velocity_indicator').css
        paddingTop: "#{totalPadding}em"
        height: "#{velocity}em"
    else
      $('#sequence_velocity_indicator').css
        paddingTop: "#{ticketsThatFit * 1.5}em"
        height: "#{ticketsThatFit * 2}em"
  
  
  
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
    
    @adjustVelocityIndicatorHeight()
  
  
  
  prependTicketTo: (ticket, $el)->
    view = new Scheduler.SequenceTicketView(ticket: ticket)
    $el.prependView(view)
    view.$el
  
  
  
  triggerEdit: ->
    @ticketSelection().first().trigger('edit:begin')
  
  cancelEdit: ->
    @viewInEdit.cancelEdit() if @viewInEdit
    @viewInEdit = null
  
  beginEdit: (e, view)->
    @cancelEdit() if @viewInEdit isnt view
    @viewInEdit = view
