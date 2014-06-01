class Scheduler.EditBugsSeverityView extends Backbone.View
  className: "edit-severity-view hide-completed"
  
  
  events:
    'click #show_completed_tickets': 'toggleShowCompleted'
  
  
  initialize: ->
    @template = HandlebarsTemplates['houston-scheduler/tickets/edit_bugs_severity']
    @ticketsTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_bugs_severity_tickets']
    @tickets = @options.tickets
    @visibleTickets = @tickets.withoutSeverityEstimate()
    
    @tickets.on 'change', _.bind(@render, @)
    
    @$el.on 'click', 'th', (e)=> @toggleSort $(e.target).closest('th')
    
    @$el.on 'click', '[rel="ticket"]', (e)=>
      e.preventDefault()
      e.stopImmediatePropagation()
      number = +$(e.target).closest('[rel="ticket"]').attr('data-number')
      App.showTicket number, null,
        tickets: @visibleTickets
        taskView: (el, ticket, options)-> new Scheduler.EditBugSeverityView
          el: el
          ticket: ticket
          prev: options.prev
  
  
  
  render: ->
    @$el.html @template()
    @$tickets = @$el.find('#tickets')
    @renderTickets()
    @
  
  renderTickets: ->
    tickets = @visibleTickets.map (ticket)->
      json = ticket.toJSON()
      json.severity = ticket.severity()
      json.saved = !!json.severity
      json
    @$tickets.html @ticketsTemplate(tickets: tickets)
    @$tickets.find('.ticket').pseudoHover()
  
  
  toggleShowCompleted: (e)->
    $button = $(e.target)
    if $button.hasClass('active')
      $button.removeClass('btn-success')
      @visibleTickets = @tickets.withoutSeverityEstimate()
      @renderTickets()
    else
      $button.addClass('btn-success')
      @visibleTickets = @tickets
      @renderTickets()



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
    @visibleTickets = @visibleTickets.orderBy(attribute, order)
    @renderTickets()
