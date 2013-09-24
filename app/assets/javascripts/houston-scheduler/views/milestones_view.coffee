class Scheduler.MilestonesView extends Scheduler.ShowTicketsView
  
  events:
    'click #new_milestone': 'newMilestone'
    'submit #new_milestone_form': 'createMilestone'
    'click #cancel_new_milestone_button': 'resetNewMilestone'
  
  initialize: ->
    super
    @milestones = @options.milestones
    
    @ticketsWithoutMilestones = @tickets.withoutMilestones()
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/milestones/index']
    html = template()
    @$el.html(html)
    
    @renderShowEffortOption()
    @renderTickets()
    @renderMilestones()
    
    @$el.find('.sequence-list').multiselectable()
    @$el.find('.sequence-ticket').draggable
      revert: true
      revertDuration: 200
      containment: '#houston_scheduler_view'
  
  renderTickets: ->
    $unsortedTickets = @$el.find('#unsorted_tickets')
    for ticket in @ticketsWithoutMilestones
      $unsortedTickets.appendView(new Scheduler.SequenceTicketView(ticket: ticket))
    
  renderMilestones: ->
    $milestones = @$el.find('#milestones')
    $milestones.empty()
    @milestones.each (milestone)=>
      view = @milestoneView(milestone)
      $milestones.appendView(view)
      view.on 'drop', ($ticket)=>
        $ticket.remove()
        ticketId = $ticket.attr('data-ticket-id')
        ticket = @tickets.get(ticketId)
        view.addTicket(ticket)
  
  newMilestone: ->
    $('#new_milestone').hide()
    $('#new_milestone_form').show()
    $('#new_milestone_name').select()
  
  createMilestone: (e)->
    e.preventDefault()
    $('#new_milestone_form').disable()
    attributes = 
      name: $('#new_milestone_name').val()
      projectId: @project.id
    @milestones.create attributes,
      wait: true
      success: (milestone)=>
        @$el.find('#milestones').appendView @milestoneView(milestone)
        @resetNewMilestone()
      error: (milestone, jqXhr)=>
        $('#new_milestone_form').enable()
        console.log('error', arguments)
        alert(jqXhr.responseText)
  
  milestoneView: (milestone)->
    new Scheduler.MilestoneView(milestone: milestone)
  
  resetNewMilestone: ->
    $('#new_milestone').show()
    $('#new_milestone_form').enable().hide()
    $('#new_milestone_name').val('')
