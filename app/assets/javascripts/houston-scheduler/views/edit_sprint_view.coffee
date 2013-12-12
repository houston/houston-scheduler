class Scheduler.EditSprintView extends Scheduler.ShowTicketsView
  
  initialize: ->
    super
    @project = @options.project
    @sprintId = @options.sprintId
    @ticketsOutsideSprint = []
    @ticketsInsideSprint = []
    @tickets.sortedBySequence().each (ticket)=>
      if ticket.get('sprintId') == @sprintId
        @ticketsInsideSprint.push ticket
      else
        @ticketsOutsideSprint.push ticket
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/sprints/edit']
    html = template()
    @$el.html(html)
    
    $('#update_sprint_button').click _.bind(@updateSprint, @)
    
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
  
  
  
  updateSprint: (e)->
    e.preventDefault()
    ticketIds = ($(el).attr('data-ticket-id') for el in $('#tickets_inside_sprint .sequence-ticket'))
    if ticketIds.length == 0
      $('#body').prepend '<div class="alert alert-warning">You haven\'t moved any tickets into this sprint'
    else
      xhr = $.put "/scheduler/sprints/#{@sprintId}",
        ticket_ids: ticketIds
      xhr.success =>
        window.location.hash = "sprint"
