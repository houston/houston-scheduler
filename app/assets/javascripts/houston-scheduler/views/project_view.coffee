class Scheduler.ProjectView extends Backbone.View
  
  
  initialize: ->
    @project = @options.project
    @tickets = @options.tickets
    @milestones = @options.milestones
    @maintainers = @options.maintainers
    @velocity = @options.velocity
    @sprintId = @options.sprintId
    @canEstimate = @options.canEstimate
    @canPrioritize = @options.canPrioritize
    @tickets.on 'change', _.bind(@render, @)
    @router = new Scheduler.Router(parent: @)
    
    for ticket in @tickets.models
      milestoneId = ticket.get('milestoneId')
      @milestones.get(milestoneId).tickets.push(ticket) if milestoneId
    
    Backbone.history.start()
    @render()
  
  
  ticketsWithoutSequence: -> @tickets.withoutSequence()
  ticketsWithBothEstimates: -> @tickets.withBothEstimates()
  ticketsUnableToEstimate: -> @tickets.unableToEstimate()
  ticketsWithEffortEstimate: -> @tickets.withEffortEstimate()
  ticketsInSprint: -> if @sprintId then @tickets.inSprint(@sprintId) else []
  
  ticketsWaitingForEffortEstimate: ->
    @tickets.select (ticket)->
      (+ticket.get('estimatedEffort') == 0) && !ticket.get('unableToSetEstimatedEffort')
  
  ticketsWaitingForValueEstimate: ->
    @tickets.select (ticket)->
      (+ticket.get('estimatedValue') == 0) && !ticket.get('unableToSetEstimatedValue')
  
  
  showTab: (view)->
    @currentView.cleanup() if @currentView?.cleanup
    @currentView = view
    $('#sequence_settings').empty()
    $(@el).empty().appendView(view)
  
  
  render: ->
    if @canPrioritize
      count = @ticketsWithoutSequence().length
      $('.tickets-without-sequence').html(count).toggleClass('zero', count == 0)
      
      count = @ticketsWaitingForValueEstimate().length
      $('.tickets-without-value-count').html(count).toggleClass('zero', count == 0)
    
    if @canEstimate
      count = @ticketsUnableToEstimate().length
      $('.tickets-unable-to-estimate-count').html(count).toggleClass('zero', count == 0)
      
      count = @ticketsWaitingForEffortEstimate().length
      $('.tickets-without-effort-count').html(count).toggleClass('zero', count == 0)
    
    count = @ticketsInSprint().length
    $('.tickets-in-sprint-count').html(count).toggleClass('zero', count == 0)
