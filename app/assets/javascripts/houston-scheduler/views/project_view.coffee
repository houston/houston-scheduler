class Scheduler.ProjectView extends Backbone.View
  
  
  initialize: ->
    @project = @options.project
    @tickets = @options.tickets
    @maintainers = @options.maintainers
    @velocity = @options.velocity
    @canEstimate = @options.canEstimate
    @canPrioritize = @options.canPrioritize
    @tickets.on 'change', _.bind(@render, @)
    @tickets.on 'add', _.bind(@refresh, @)
    @router = new Scheduler.Router(parent: @)
    
    Backbone.history.start()
    @render()
  
  
  ticketsReadyToPrioritize: -> @tickets.unpostponed().ableToPrioritize()
  ticketsWaitingForSequence: -> @openTickets().ableToPrioritize().withoutSequence()
  openTickets: -> @tickets.unpostponed().unresolved()
  ticketsWaitingForDiscussion: -> @tickets.unpostponed().waitingForDiscussion()
  ticketsWaitingForEffortEstimate: -> @openTickets().withoutEffortEstimate().ableToEstimate()
  ticketsWaitingForValueEstimate: -> @openTickets().features().withoutValueEstimate(@project.valueStatements)
  ticketsWaitingForSeverityEstimate: -> @openTickets().bugs().withoutSeverityEstimate()
  ticketsWaitingForMyEffortEstimate: ->
    myEstimateKey = "estimatedEffort[#{window.user.id}]"
    @ticketsWaitingForEffortEstimate().select (ticket)-> !ticket.get(myEstimateKey)
  ticketsPostponed: -> @tickets.postponed()
  
  
  showTab: (view)->
    @currentView.cleanup() if @currentView?.cleanup
    @currentView = view
    $('#sequence_settings').empty()
    $(@el).empty().appendView(view)
  
  
  refresh: ->
    @router.reload()
    @render()
  
  render: ->
    if @canPrioritize
      count = @ticketsWaitingForSequence().length
      $('.tickets-without-sequence').html(count).toggleClass('zero', count == 0)
    
    if @canEstimate
      count = @ticketsWaitingForEffortEstimate().length
      $('.tickets-without-effort-count').html(count).toggleClass('zero', count == 0)
      
      count = @ticketsWaitingForMyEffortEstimate().length
      $('.tickets-without-my-effort-estimate-count').html(count).toggleClass('zero', count == 0)
    
    if @canPrioritize
      count = @ticketsWaitingForValueEstimate().length
      $('.features-without-value-count').html(count).toggleClass('zero', count == 0)
      
      count = @ticketsWaitingForSeverityEstimate().length
      $('.bugs-without-severity-count').html(count).toggleClass('zero', count == 0)
    
    count = @ticketsWaitingForDiscussion().length
    $('.tickets-discussion-needed-count').html(count).toggleClass('zero', count == 0)
    
    count = @ticketsPostponed().length
    $('.tickets-postponed-count').html(count).toggleClass('zero', count == 0)
