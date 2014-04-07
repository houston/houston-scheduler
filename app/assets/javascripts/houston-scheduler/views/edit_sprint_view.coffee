class Scheduler.EditSprintView extends Scheduler.ShowTicketsView
  
  events:
    'change #project_slug': 'changeProject'
  
  
  initialize: ->
    super
    @projects = @options.projects
    @sprintId = @options.sprintId
    @ticketsOutsideSprint = []
    @ticketsInsideSprint = @options.tickets or []
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/sprints/edit']
    html = template
      sprintId: @sprintId
      projects: @projects
    @$el.html(html)
    
    $('#update_sprint_button').click _.bind(@updateSprint, @)
    
    @renderTickets()
    @renderShowEffortOption()
    @updateTotalEffort()
  
  renderTickets: ->
    @renderTicketsOutsideSprint()
    
    $ticketsInsideSprint = @$el.find('#tickets_inside_sprint')
    for ticket in @ticketsInsideSprint
      $ticketsInsideSprint.appendView(new Scheduler.SequenceTicketView(ticket: ticket))
    
    @makeTicketsSortable()
    
    $ticketsInsideSprint.on 'sortreceive', (event, ui)=> @updateTotalEffort()
    $ticketsInsideSprint.on 'sortremove', (event, ui)=> @updateTotalEffort()
    
  makeTicketsSortable: ->
    super(connected: true)
  
  
  
  changeProject: ->
    slug = $('#project_slug').val()
    if slug
      $.get "/projects/#{slug}/tickets/open.json", (tickets)=>
        @ticketsOutsideSprint = tickets
        @renderTicketsOutsideSprint()
    else
      @ticketsOutsideSprint = []
      @renderTicketsOutsideSprint()
      
  renderTicketsOutsideSprint: ->
    $ticketsOutsideSprint = @$el.find('#tickets_outside_sprint')
    $ticketsOutsideSprint.empty()
    for ticket in @ticketsOutsideSprint
      $ticketsOutsideSprint.appendView new Scheduler.SequenceTicketView
        ticket: new Scheduler.Ticket(ticket)
  
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
    plus = false
    for ticket in @tickets when _.contains(ids, ticket.id)
      ticketEffort = ticket.estimatedEffort()
      if ticketEffort
        effort += +ticketEffort
      else
        plus = true
    effort = effort.toFixed(1)
    effort = "#{effort}+" if plus
    $('#total_effort').html(effort)
