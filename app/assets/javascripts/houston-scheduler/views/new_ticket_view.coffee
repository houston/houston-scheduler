class Scheduler.NewTicketView extends Backbone.View
  
  initialize: ->
    @project = @options.project
    @template = HandlebarsTemplates['houston-scheduler/tickets/new']
  
  show: ->
    $modal = $(@template()).modal()
    $modal.on 'hidden', -> $(@).remove()
    $modal.on 'shown', (e)=>
      $modal.find('input[type="text"]:first').select()
      $form = $modal.find('form')
      
      
      $modal.keydown (e)->
        $form.submit() if e.metaKey and e.keyCode is 13
      
      converter = new Markdown.Converter()
      $description = $modal.find('#ticket_description')
      $preview = $modal.find('#ticket_description_preview')
      $description.on 'paste cut keyup', (e)->
        markdown = $description.val()
        html = converter.makeHtml(markdown)
        $preview.html(html)
      
      $form.submit (e)=>
        e.preventDefault()
        
        attributes = $form.serializeObject()
        xhr = $.post "/projects/#{@project.slug}/tickets", attributes
        xhr.success (ticket)=>
          ticket.prerequisites = []
          @trigger 'created', new Scheduler.Ticket(ticket)
          $modal.modal('hide')
        
        xhr.error (response)=>
          errors = Errors.fromResponse(response)
          if errors.missingCredentials or errors.invalidCredentials
            App.promptForCredentialsTo @project.ticketTrackerName
          else
            errors.renderToAlert().appendTo($modal.find('.modal-header')).alert()
