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
      else if !ticket.get('resolved')
        @ticketsOutsideSprint.push ticket
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/sprints/edit']
    html = template()
    @$el.html(html)
    
    $('#update_sprint_button').click _.bind(@updateSprint, @)
    
    @renderShowEffortOption()
    @renderTickets()
    @updateTotalEffort()
  
  renderTickets: ->
    $ticketsOutsideSprint = @$el.find('#tickets_outside_sprint')
    for ticket in @ticketsOutsideSprint
      $ticketsOutsideSprint.appendView(new Scheduler.SequenceTicketView(ticket: ticket))
    
    $ticketsInsideSprint = @$el.find('#tickets_inside_sprint')
    for ticket in @ticketsInsideSprint
      $ticketsInsideSprint.appendView(new Scheduler.SequenceTicketView(ticket: ticket))
    
    @makeTicketsSortable()
    
    $ticketsInsideSprint.on 'sortreceive', (event, ui)=> @updateTotalEffort()
    $ticketsInsideSprint.on 'sortremove', (event, ui)=> @updateTotalEffort()
    
  makeTicketsSortable: ->
    super(connected: true)
  
  
  
  updateSprint: (e)->
    e.preventDefault()
    ticketIds = @selectedTicketIds()
    if ticketIds.length == 0
      $('#body').prepend '<div class="alert alert-warning">You haven\'t moved any tickets into this sprint'
    else
      xhr = $.put "/scheduler/sprints/#{@sprintId}",
        ticket_ids: ticketIds
      xhr.success =>
        window.location.hash = "sprint"

  selectedTicketIds: ->
    (+$(el).attr('data-ticket-id') for el in $('#tickets_inside_sprint .sequence-ticket'))

  updateTotalEffort: ->
    ids = @selectedTicketIds()
    effort = 0
    for ticket in @tickets.toJSON() when _.contains(ids, ticket.id)
      effort += +ticket.estimatedEffort
    $('#total_effort').html(effort.toFixed(1))
