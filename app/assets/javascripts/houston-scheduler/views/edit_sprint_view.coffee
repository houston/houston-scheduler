class Scheduler.EditSprintView extends Scheduler.ShowTicketsView
  
  initialize: ->
    super
    @project = @options.project
    @sprintId = @options.sprintId
    @ticketsOutsideSprint = []
    @ticketsInsideSprint = []
    @tickets.each (ticket)=>
      if ticket.get('sprintId') == @sprintId
        @ticketsInsideSprint.push ticket
      else
        @ticketsOutsideSprint.push ticket
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/sprints/edit']
    html = template()
    @$el.html(html)
    
    @renderShowEffortOption()
    @renderTickets()
  
  renderTickets: ->
    $ticketsOutsideSprint = @$el.find('#tickets_outside_sprint')
    for ticket in @ticketsOutsideSprint
      $ticketsOutsideSprint.appendView(new Scheduler.SequenceTicketView(ticket: ticket))
    
    $ticketsInsideSprint = @$el.find('#tickets_inside_sprint')
    for ticket in @ticketsInsideSprint
      $ticketsInsideSprint.appendView(new Scheduler.SequenceTicketView(ticket: ticket))
    
    @makeTicketsSortable()
    
  makeTicketsSortable: ->
    super(connected: true)
