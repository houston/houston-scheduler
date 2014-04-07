class Scheduler.NewSprintView extends Scheduler.EditSprintView
  
  render: ->
    super
    
    template = HandlebarsTemplates['houston-scheduler/sprints/new']
    @$el.find('#sprint_instructions').html(template)
    
    $('#create_sprint_button').click _.bind(@createSprint, @)
  
  createSprint: (e)->
    e.preventDefault()
    ticketIds = ($(el).attr('data-ticket-id') for el in $('#tickets_inside_sprint .sequence-ticket'))
    if ticketIds.length == 0
      $('#body').prepend '<div class="alert alert-warning">You haven\'t moved any tickets into this sprint'
    else
      xhr = $.post '/scheduler/sprints',
        ticket_ids: ticketIds
      xhr.success @options.onCreated
