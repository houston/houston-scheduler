class Scheduler.ProjectView extends Backbone.View
  
  
  events:
    'click .nav-tabs li': 'selectTab'
  
  
  
  initialize: ->
    @tickets = @options.tickets
    @tickets.on 'change', _.bind(@render, @)
    @router = new Scheduler.Router
      parent: @
    
    Backbone.history.start()
    @render()
  
  
  ticketsWithBothEstimates: -> @tickets.withBothEstimates()
  ticketsWithNoEffort: -> @tickets.withNoEffortEstimate()
  ticketsWithNoValue: -> @tickets.withNoValueEstimate()
  
  
  
  showTab: (view)->
    $(@el).empty().appendView(view)
  
  
  render: ->
    $('.tickets-without-effort-count').html(@ticketsWithNoEffort().length);
    $('.tickets-without-value-count').html(@ticketsWithNoValue().length);
  
  
  selectTab: (e)->
    
