class Scheduler.EditTicketEffortView extends Backbone.View
  
  events:
    'change input': 'saveValue'
    'keypress input': 'onKeyPress'
    'click .btn-unable-to-estimate': 'onToggleUnableToEstimate'
  
  initialize: ->
    @ticket = @options.ticket
    @template = HandlebarsTemplates['houston-scheduler/tickets/edit_effort']
    @$el.addClass('estimate-effort')
  
  render: ->
    json = @ticket.toJSON()
    json.tasks = @ticket.tasks().toJSON()
    @$el.html @template(json)
    
    # Allow scrolling with mousewheel rather than
    # spinning a ticket's effort estimate up or down
    @$el.delegate 'input[type="number"]', 'mousewheel', -> $(@).blur()
    
    @$el.find('input:first').focus()
    @$el.find('[data-toggle="tooltip"]').tooltip()
    @$el.toggleClass('saved', @ticket.estimated())
    @unableToEstimate() if @ticket.get('unableToSetEstimatedEffort')
    @
  
  
  
  saveChanges: ->
    @$el.find('input:first').blur()
  
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
    @$el.find('.btn-unable-to-estimate').addClass('active btn-danger')
    @$el.find('input').attr('disabled', 'disabled')
  
  ableToEstimate: ->
    @$el.removeClass('unable-to-estimate unable-to-estimate-on-render')
    @$el.find('.btn-unable-to-estimate').removeClass('active btn-danger')
    @$el.find('input').removeAttr('disabled').focus().select()



  onKeyPress: (e)->
    character = String.fromCharCode(e.charCode)
    value = $(e.target).val() + character
    e.preventDefault() unless /^[\d\.]+$/.test(value)
