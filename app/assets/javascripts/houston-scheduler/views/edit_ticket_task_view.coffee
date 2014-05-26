class Scheduler.EditTicketTaskView extends Backbone.View
  tagName: 'tr'
  className: 'ticket-task'
  
  initialize: ->
    @task = @options.task
    @template = HandlebarsTemplates['houston-scheduler/tickets/task']
  
  render: ->
    @$el.attr('id', "task_#{@task.id}")
    @$el.attr('data-id', @task.id)
    @$el.html @template(@task.toJSON())
    @$description = @$el.find('task-description')
    @
