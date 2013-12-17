class Scheduler.EditTicketEffortView2 extends Backbone.View
  className: 'edit-estimates-view2'
  
  initialize: ->
    @template = HandlebarsTemplates['houston-scheduler/tickets/edit_tickets_effort2']
    @tickets = @options.tickets
    @maintainers = @options.maintainers
    @myEstimateKey = "estimatedEffort[#{window.user.id}]"
    @allEstimateKeys = ("estimatedEffort[#{maintainer.id}]" for maintainer in @maintainers)
    
    @$el.on 'click', '[role="menuitem"]', _.bind(@setEstimate, @)
  
  render: ->
    tickets = @tickets.map (ticket)=>
      ticket = ticket.toJSON()
      ticket.myEstimate = ticket[@myEstimateKey]
      ticket.estimates = (ticket[key] for key in @allEstimateKeys when ticket[key])
      ticket.complete = @isComplete(ticket)
      ticket
    @$el.html @template
      tickets: tickets
      maintainers: @maintainers
    
    @$el.loadTicketDetailsOnClick()
    
    $('.table-sortable').tablesorter()
    @
  
  isComplete: (ticket)->
    _.intersection(_.keys(ticket), @allEstimateKeys).length == @allEstimateKeys.length
  
  setEstimate: (e)->
    e.preventDefault()
    $a = $(e.target)
    ticketId = $a.closest('.ticket').data('ticket-id')
    estimate = $a.html()
    
    $a.closest('.dropdown').find('.estimate').removeClass('no-estimate').html(estimate)
    ticket = @tickets.get(ticketId)
    attributes = {}
    attributes[@myEstimateKey] = estimate
    ticket.save attributes, patch: true
    @render() # <-- maybe render just the ticket in the future

  