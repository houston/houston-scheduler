KEYS =
  13: "RETURN"
  27: "ESC"
  38: "UP"
  40: "DOWN"

class Scheduler.EditTicketsEffortView extends Backbone.View
  className: "edit-estimates-view hide-completed"
  
  
  events:
    'keydown input': 'onKeyDown'
    'keypress input': 'onKeyPress'
    'click #show_completed_tickets': 'toggleShowCompleted'
  
  
  keyDownHandlers:
    UP:     -> @putFocusOn @prevLine()
    DOWN:   -> @putFocusOn @nextLine()
  
  
  initialize: ->
    @template = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort']
    @tickets = @options.tickets
    
    # Allow scrolling with mousewheel rather than
    # spinning a ticket's effort estimate up or down
    @$el.delegate 'input[type="number"]', 'mousewheel', -> $(@).blur()
    @$el.delegate '.ticket', 'click', (e)->
      $(@).find('input:first').focus() unless $(e.target).is('input')
    @$el.delegate 'input', 'focus', -> $(@).closest('.ticket').addClass('focus')
    @$el.delegate 'input', 'blur', -> $(@).closest('.ticket').removeClass('focus')
    
    @$el.loadTicketDetailsOnClick()
    @$el.on 'click', 'th', (e)=> @toggleSort $(e.target).closest('th')
  
  
  
  render: ->
    $(@el).html @template()
    @$list = $('#tickets')
    @refresh()
    @
  
  refresh: ->
    @$list.find('tbody').remove()
    @tickets.each (ticket)=>
      view = new Scheduler.EditTicketEffortView(ticket: ticket)
      @$list.appendView(view)
  
  
  onKeyDown: (e)->
    keyName = @identifyKey(e.keyCode)
    handler = @keyDownHandlers[keyName]
    if handler
      e.preventDefault()
      handler.apply(@)
  
  onKeyPress: (e)->
    character = String.fromCharCode(e.charCode)
    value = $(e.target).val() + character
    e.preventDefault() unless /[\d\.]+/.test(value)

    if character == 'm'
      $ticket = $('.ticket.focus')
      Scheduler.loadTicketDetails $ticket.find('a.ticket-details').attr('href'), ->
        $ticket.find('input').focus()
    
  identifyKey: (code)->
      KEYS[code]
  
  
  putFocusOn: ($line)->
    $line.find('input:first').focus()
  
  prevLine: ->
    $prev = @thisLine().prev()
    if $prev.length == 0
      $prevTicket = @thisLine().closest('tbody').prev()
      $prevTicket = $prevTicket.prev() while $prevTicket.is('.unable-to-estimate, .saved-on-render')
      $prev = $prevTicket.find('tr:last')
    $prev
    
  nextLine: ->
    $next = @thisLine().next()
    if $next.length == 0
      $nextTicket = @thisLine().closest('tbody').next()
      $nextTicket = $nextTicket.next() while $nextTicket.is('.unable-to-estimate, .saved-on-render')
      $next = $nextTicket.find('tr:first')
    $next
    
  thisLine: ->
    $('input:focus').closest('tr')
  
  
  
  toggleShowCompleted: (e)->
    $button = $(e.target)
    if $button.hasClass('active')
      $button.removeClass('btn-success')
      @$el.addClass('hide-completed')
    else
      $button.addClass('btn-success')
      @$el.removeClass('hide-completed')



  toggleSort: ($th)->
    if $th.hasClass('sort-asc')
      $th.removeClass('sort-asc').addClass('sort-desc')
    else if $th.hasClass('sort-desc')
      $th.removeClass('sort-desc').addClass('sort-asc')
    else
      @$el.find('.sort-asc, .sort-desc').removeClass('sort-asc sort-desc')
      $th.addClass('sort-desc')
    
    attribute = $th.attr('data-attribute')
    order = if $th.hasClass('sort-desc') then 'desc' else 'asc'
    @performSort attribute, order
  
  performSort: (attribute, order)->
    sorter = @["#{attribute}Sorter"]
    return console.log "#{attribute}Sorter is undefined!" unless sorter
    
    @tickets = @tickets.sortBy(sorter)
    @tickets = @tickets.reverse() if order == 'desc'
    @refresh()

  sequenceSorter: (ticket)-> ticket.get('sequence')
  effortSorter: (ticket)-> ticket.estimatedEffort()
  summarySorter: (ticket)-> ticket.get('summary').toLowerCase().replace(/^\W/, '')
  createdAtSorter: (ticket)-> ticket.get('createdAt')
