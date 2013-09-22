class Scheduler.ShowMilestoneView extends Scheduler.ShowTicketsView
  
  initialize: ->
    super
    @render()
  
  render: ->
    @renderShowEffortOption()
    @renderTickets()
  
  renderTickets: ->
    $tickets = @$el.find('#tickets')
    for ticket in @tickets
      $tickets.appendView(new Scheduler.SequenceTicketView(ticket: ticket))
