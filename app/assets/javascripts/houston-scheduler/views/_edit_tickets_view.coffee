class Scheduler.EditTicketsView extends Backbone.View
  tagName: 'ol'
  
  
  initialize: ->
    @template = HandlebarsTemplates[@templatePath]
    @tickets = @options.tickets
  
  
  render: ->
    $(@el).attr('id', 'tickets').empty()
    @tickets.each (ticket)=>
      view = new Scheduler.EditTicketView
        ticket: ticket
        template: @template
        isValid: _.bind(@isValid, @)
      $(@el).appendView(view)
    @
