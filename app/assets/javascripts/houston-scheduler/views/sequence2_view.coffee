class Scheduler.Sequence2View extends Backbone.View
  
  
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
      if $(e.target).closest('.sequence2-list').length == 0
        $('.sequence2-list .selected').removeClass('selected')
    
    @sortedTickets = @tickets.sorted()
    @unsortedTickets = @tickets.unsorted()
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tickets/sequence2']
    html = template
      projectName: @project.name
      velocity: @velocity
      showInstuctions: !@readonly
    @$el.html(html)
    
    $('#sequence2_settings').html '''
      <label for="sequence2_show_effort">
        <input type="checkbox" id="sequence2_show_effort" checked="checked" />
        Show Effort
      </label>
    '''
    $('#sequence2_show_effort').click (e)=>
      @showEffort = $(e.target).is(':checked')
      @showOrHideEffort()
    
    $unsortedTickets = @$el.find('#sequence2_unsorted')
    $sortedTickets = @$el.find('#sequence2_sorted')
    
    @$el.find('.sequence2-explanation').popover()
    
    $unsortedTickets.appendView(new Scheduler.Sequence2TicketView(ticket: ticket)) for ticket in @unsortedTickets
    $sortedTickets.appendView(new Scheduler.Sequence2TicketView(ticket: ticket)) for ticket in @sortedTickets
    
    @$el.find('.sequence2-ticket').pseudoHover()
    
    unless @readonly
      view = @
      @$el.find('.sequence2-list').multisortable
        connectWith: '.sequence2-list'
        activate: (event, ui)-> $(@).addClass('sort-active')
        deactivate: (event, ui)-> $(@).removeClass('sort-active')
        
        # unselect items in the opposite list
        click: (event, e)->
          $('.sequence2-list').not(e.parent()).find('.selected').removeClass('selected')
      
      @$el.find('#sequence2_sorted').on 'sortupdate', (event, ui)=>
        @delayedNotifier.trigger()
        @adjustVelocityIndicatorHeight()
    
    @adjustVelocityIndicatorHeight()
    
    $indicator = $('#sequence2_velocity_help')
    $indicator.popover
      placement: 'left'
      trigger: 'hover'
      title: 'Velocity'
      content: 'This bar indicates this project\'s velocity. Any tickets that fit within its height should fit within one week of development.'
    
    @
  
  
  
  updateOrder: ->
    $tickets = $('#sequence2_sorted .sequence2-ticket')
    ids = _.map $tickets, (el)-> $(el).attr('data-ticket-id')
    ids = "empty" if $tickets.length == 0
    url = window.location.pathname + '/ticket_order'
    $.put url, {order: ids}
    
  moveUp: (e)->
    e.preventDefault()
    e.stopImmediatePropagation()
    $ticket = $(e.target).closest('.sequence2-ticket')
    $prev = $ticket.prev()
    $ticket.remove().insertBefore($prev).pseudoHover() if $prev.length > 0
  
  moveDown: (e)->
    e.preventDefault()
    e.stopImmediatePropagation()
    $ticket = $(e.target).closest('.sequence2-ticket')
    $next = $ticket.next()
    $ticket.remove().insertAfter($next).pseudoHover() if $next.length > 0
  
  
  
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
    $('#sequence2_sorted .sequence2-ticket').each (i)->
      effort = $(@).attr('data-effort')
      effort = if effort then +effort else 10
      totalEffort += effort
      return false if totalEffort >= velocity
      totalPadding += 1.5
      ticketsThatFit += 1
    
    if @showEffort
      $('#sequence2_velocity_indicator').css
        paddingTop: "#{totalPadding}em"
        height: "#{velocity}em"
    else
      $('#sequence2_velocity_indicator').css
        paddingTop: "#{ticketsThatFit * 1.5}em"
        height: "#{ticketsThatFit * 2}em"
  
  
  
  showOrHideEffort: ->
    if @showEffort
      $('.sequence2-ticket').each ->
        $ticket = $(@)
        effort = $ticket.attr('data-effort')
        effort = if effort then +effort else 10
        $ticket.css('height', "#{effort}em")
    else
      $('.sequence2-ticket').each ->
        $(@).css('height', '2em')
    
    @adjustVelocityIndicatorHeight()
