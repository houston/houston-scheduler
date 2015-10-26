class Scheduler.EditTicketTaskView extends Backbone.View
  tagName: 'tr'
  className: 'ticket-task'

  events:
    'click .delete-link': 'deleteTask'

  initialize: ->
    @ticket = @options.ticket
    @task = @options.task
    @template = HandlebarsTemplates['houston/scheduler/tickets/task']

  render: ->
    @$el.attr('id', "task_#{@task.id}")
    @$el.attr('data-id', @task.id)
    @$el.html @template(@task.toJSON())
    @$description = @$el.find('task-description')
    @

  deleteTask: (e)->
    e.preventDefault()
    xhr = @ticket.deleteTask(@task)
    xhr.error ->
      console.log 'error', arguments
