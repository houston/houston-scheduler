class Scheduler.EditTicketsEffortView extends Backbone.View
  className: "edit-estimates-view hide-completed"
  
  
  events:
    'click #show_completed_tickets': 'toggleShowCompleted'
  
  
  initialize: ->
    @template = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort']
    @ticketsTemplate = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort_tickets']
    @tickets = @options.tickets
    @visibleTickets = @tickets.ableToEstimate().withoutEffortEstimate()
    
    @tickets.on 'change', _.bind(@render, @)
    
    @$el.on 'click', 'th', (e)=> @toggleSort $(e.target).closest('th')
    
    @$el.on 'click', '[rel="ticket"]', (e)=>
      e.preventDefault()
      e.stopImmediatePropagation()
      number = +$(e.target).closest('[rel="ticket"]').attr('data-number')
      App.showTicket number, null,
        tickets: @visibleTickets
        taskView: (el, ticket)-> new Scheduler.EditTicketEffortView
          el: el
          ticket: ticket
  
  
  
  render: ->
    @$el.html @template()
    @$tickets = @$el.find('#tickets')
    @renderTickets()
    @
  
  renderTickets: ->
    tickets = @visibleTickets.map (ticket)->
      json = ticket.toJSON()
      json.effort = ticket.estimatedEffort()
      json.saved = ticket.estimated()
      json
    @$tickets.html @ticketsTemplate(tickets: tickets)
    @$tickets.find('.ticket').pseudoHover()
  
  
  toggleShowCompleted: (e)->
    $button = $(e.target)
    if $button.hasClass('active')
      $button.removeClass('btn-success')
      @visibleTickets = @tickets.ableToEstimate().withoutEffortEstimate()
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
