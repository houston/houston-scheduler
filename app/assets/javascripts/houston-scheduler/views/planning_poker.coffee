class Scheduler.PlanningPoker extends Backbone.View
  className: 'planning-poker'
  
  initialize: ->
    @template = HandlebarsTemplates['houston-scheduler/tickets/planning_poker']
    @tickets = @options.tickets
    @maintainers = @options.maintainers
    @myEstimateKey = "estimatedEffort[#{window.user.id}]"
    @allEstimateKeys = ("estimatedEffort[#{maintainer.id}]" for maintainer in @maintainers)
    
    @$el.on 'click', '[role="menuitem"]', _.bind(@setEstimate, @)
  
  render: ->
    tickets = @tickets.map (ticket)=>
      ticket = ticket.toJSON()
      ticket.myEstimate = ticket[@myEstimateKey]
      ticket.estimates = for key in @allEstimateKeys when ticket[key]
        estimate = ticket[key]
        estimate = '—' if estimate is 'Pass'
        estimate = 'Ø' if estimate is 'Unestimatable Ticket'
        estimate
      ticket.complete = @isComplete(ticket)
      ticket.unanimous = @isUnanimous(ticket)
      ticket
    @$el.html @template
      tickets: tickets
      maintainers: @maintainers
    
    $('.table-sortable').tablesorter
      headers:
        1: {sorter: 'sequence'}
    @
  
  isComplete: (ticket)->
    _.intersection(_.keys(ticket), @allEstimateKeys).length == @allEstimateKeys.length
  
  estimates: (ticket)->
    _.map(@allEstimateKeys, (key)-> ticket[key])
  
  isUnanimous: (ticket)->
    _.uniq(@estimates(ticket)).length is 1
  
  setEstimate: (e)->
    e.preventDefault()
    $a = $(e.target)
    ticketId = $a.closest('.ticket').data('ticket-id')
    estimate = $a.html()
    
    if estimate is 'No Estimate'
      estimate = ''
      $a.closest('.dropdown').find('.estimate').addClass('no-estimate').html(estimate)
    else
      $a.closest('.dropdown').find('.estimate').removeClass('no-estimate').html(estimate)
    ticket = @tickets.get(ticketId)
    
    attributes = {}
    attributes[@myEstimateKey] = estimate
    
    allAttributes = ticket.toJSON()
    allAttributes[@myEstimateKey] = estimate
    if @isUnanimous(allAttributes)
      switch estimate
        when 'Unestimatable Ticket'
          attributes['estimatedEffort'] = ''
          attributes['unableToSetEstimatedEffort'] = true
        when 'Pass'
          # do nothing
        else
          attributes['estimatedEffort'] = estimate
          attributes['unableToSetEstimatedEffort'] = false
    else
      attributes['estimatedEffort'] = ''
    
    ticket.save attributes, patch: true
    @render() # <-- maybe render just the ticket in the future

  