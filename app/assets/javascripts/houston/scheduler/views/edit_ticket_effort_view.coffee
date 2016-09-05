class Scheduler.EditTicketEffortView extends Backbone.View

  events:
    'change input[type="number"]': 'saveValue'
    'keypress input[type="number"]': 'onKeyPress'
    'keydown input[type="number"]': 'onKeyDown'
    'click .btn-unable-to-estimate': 'onToggleUnableToEstimate'
    'click #add_task_button': 'addTask'

  initialize: (options)->
    @options = options
    @ticket = @options.ticket
    @prev = @options.prev
    @ticket.on 'change:tasks', _.bind(@render, @)
    @template = HandlebarsTemplates['houston/scheduler/tickets/edit_effort']
    @$el.addClass('estimate-effort')

  render: ->
    @$el.html @template()
    $tasks = @$el.find('#tasks')
    $tasks.attr('task-count', @ticket.tasks().length)
    @ticket.tasks().each (task)=>
      $tasks.appendView new Scheduler.EditTicketTaskView
        ticket: @ticket
        task: task

    # Allow scrolling with mousewheel rather than
    # spinning a ticket's effort estimate up or down
    @$el.delegate 'input[type="number"]', 'mousewheel', -> $(@).blur()

    @$el.find("input:#{if @prev then 'last' else 'first'}").focus()
    @$el.find('[data-toggle="tooltip"]').tooltip()
    @$el.toggleClass('saved', @ticket.estimated())
    @unableToEstimate() if @ticket.get('unableToSetEstimatedEffort')
    @



  saveChanges: ->
    @$el.find('input:focus').blur()

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

  onKeyDown: (e)->
    if e.keyCode == 40
      $input = $(e.target)
      $nextInput = $input.closest('tr').next().find('input[type="number"]')
      if $nextInput.length > 0
        e.stopImmediatePropagation()
        e.preventDefault()
        $nextInput.focus().select()

    if e.keyCode == 38
      $input = $(e.target)
      $prevInput = $input.closest('tr').prev().find('input[type="number"]')
      if $prevInput.length > 0
        e.stopImmediatePropagation()
        e.preventDefault()
        $prevInput.focus().select()



  addTask: (e)->
    e.preventDefault()
    $('#add_task_button').hide()
    @$el.find('#tasks').append """
    <tr class="ticket-task" id="new_task">
      <td class="task-letter">
        #{@ticket.nextTaskLetter()}.
      </td>
      <td class="task-description">
        <input type="text" name="description"/>
      </td>
      <td class="task-effort">
        <input type="number" step="any" min="0.1" value="{{effort}}" name="effort" class="task-effort mousetrap" />
      </td>
    </tr>
    """
    $task = $('#new_task')
    $task.find('input:first').focus().select()
    $task.keydown (e)=>
      if e.keyCode == 27
        @cancelNewTask()
      if e.keyCode == 13
        e.stopImmediatePropagation()
        e.preventDefault()
        @createTask $task.serializeFormElements()

  cancelNewTask: ->
    $('#new_task').remove()
    $('#add_task_button').show()

  createTask: (attributes)->
    xhr = @ticket.addTask(attributes)
    xhr.success => @cancelNewTask()
    xhr.error ->
      console.log 'error', arguments
