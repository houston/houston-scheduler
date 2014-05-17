class Scheduler.EditTicketEffortView extends Backbone.View
  tagName: 'tbody'
  className: 'ticket'
  
  events:
    'change input': 'saveValue'
    'click .btn-unable-to-estimate': 'onToggleUnableToEstimate'
  
  
  
  initialize: ->
    @ticket = @options.ticket
    @template = HandlebarsTemplates['houston-scheduler/tickets/edit_effort']
  
  render: ->
    ticket = @ticket.toJSON()
    ticket.task0 = ticket.tasks[0]
    ticket.otherTasks = ticket.tasks.slice(1)
    ticket.tasks = ticket.tasks.length
    @$el
      .attr('id', "ticket_#{@ticket.get('id')}")
      .html(@template ticket)
      .toggleClass('saved saved-on-render', @ticket.estimated())
    if @ticket.get('unableToSetEstimatedEffort')
      @$el.addClass('unable-to-estimate-on-render')
      @unableToEstimate()
    @
  
  
  
  saveValue: (e)->
    $task = $(e.target).closest('.ticket-task')
    task = @ticket.tasks().get $task.attr('data-id')
    attributes = $task.serializeFormElements()
    return unless task
    
    @saveAttributes task, attributes, =>
      @ticket.trigger 'change'
      @$el.toggleClass('saved', @ticket.estimated())
  
  saveAttributes: (model, attributes, callback)->
    model.save attributes,
      patch: true
      beforeSend: =>
        @$el.addClass 'working'
      success: =>
        @$el.removeClass 'working'
        callback()
      error: =>
        console.log arguments
        @$el.removeClass 'working'
      complete: =>
        @$el.removeClass 'working'
  
  
  
  onToggleUnableToEstimate: (e)->
    e.preventDefault()
    
    attributes = {}
    attributes['unableToSetEstimatedEffort'] = disableMe = if @$el.hasClass('unable-to-estimate') then null else true
    @unableToEstimate() if disableMe
    
    @saveAttributes @ticket, attributes, =>
      @updateAbilityToEstimate()
  
  updateAbilityToEstimate: ->
    if @ticket.get('unableToSetEstimatedEffort')
      @unableToEstimate()
    else
      @ableToEstimate()
  
  unableToEstimate: ->
    @$el.addClass('unable-to-estimate').removeClass('focus')
    @$el.find('button').addClass('active')
    @$el.find('input').attr('disabled', 'disabled')
  
  ableToEstimate: ->
    @$el.removeClass('unable-to-estimate unable-to-estimate-on-render')
    @$el.find('button').removeClass('active')
    @$el.find('input').removeAttr('disabled').focus().select()
