class Scheduler.NewTicketView extends Backbone.View
  
  FEATURE_DESCRIPTION: '''
### Make sure that
 - 
  '''

  BUG_DESCRIPTION: '''
### Steps to Test
 - 

### What happens
 - 

### What should happen
 - 
  '''
  
  events:
    'click #reset_ticket': 'resetNewTicket'
    'click #create_ticket': 'createNewTicket'
  
  initialize: ->
    @project = @options.project
    @template = HandlebarsTemplates['houston-scheduler/tickets/new']
    
    Mousetrap.bind ['ctrl+enter', 'command+enter'], (e)=>
      if $('#new_ticket_form :focus').length > 0
        @createNewTicket()
  
  render: ->
    @$el.html @template()
    
    onTicketSummaryChange = _.bind(@onTicketSummaryChange, @)
    $('#ticket_summary').keydown (e)=>
      if e.keyCode is 13
        e.preventDefault()
        $('#ticket_description').focus()
    $('#ticket_summary').keyup onTicketSummaryChange
    $('#ticket_summary').change onTicketSummaryChange
    
    firstWordOf = (query)->
      result = /^\s*([^\s]+)$/.exec(query) ? []
      result[1]?.trim()
      
    lastWordOf = (query)->
      result = /([^\s]+)$/.exec(query) ? []
      result[1]?.trim()
    
    view = @
    
    $('#ticket_summary')
      .attr('autocomplete', 'off')
      .typeahead
        source: ["[bug]", "[feature]", "[chore]", "[refactor]"]
        updater: (item)->
          view.autocompleteDescriptionFor(item)
          console.log 'selected', item
          @$element.val().replace(/[^\s]*$/,'') + item + ' '
        matcher: (item)->
          tquery = firstWordOf(@query)
          return false unless tquery
          ~item.toLowerCase().indexOf(tquery.toLowerCase())
        highlighter: (item)->
          query = lastWordOf(@query).replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
          item.replace new RegExp("(#{query})", 'ig'), ($1, match)->
            "<strong>#{match}</strong>"
  
  
  
  onTicketSummaryChange: ->
    summary = $('#ticket_summary').val()
    if summary.length > 0
      @showNewTicket()
    else
      @hideNewTicket()
  
  resetNewTicket: ->
    $('#ticket_summary').val ''
    $('#ticket_description').val ''
    @hideNewTicket()
  
  createNewTicket: ->
    $form = $('#new_ticket_form')
    attributes = $form.serializeObject()
    
    $form.disable()
    
    xhr = $.post "/projects/#{@project.slug}/tickets", attributes
    xhr.complete -> $form.enable()
    
    xhr.success (ticket)=>
      ticket.prerequisites = []
      @trigger 'create', new Scheduler.Ticket(ticket)
      
      $form.enable()
      @resetNewTicket()
      $('#ticket_summary').focus()
    
    xhr.error (response)=>
      errors = Errors.fromResponse(response)
      if errors.missingCredentials or errors.invalidCredentials
        App.promptForCredentialsTo @project.ticketTrackerName
      else
        errors.renderToAlert().prependTo($('#houston_scheduler_view')).alert()


  showNewTicket: ->
    $('.sequence-new-ticket-full').slideDown 200, ->
      $('#ticket_description').autosize()
    $('.sequence-list .selected').removeClass('selected')

  hideNewTicket: ->
    $('.sequence-new-ticket-full').slideUp 200

  autocompleteDescriptionFor: (type)->
    $('#ticket_description')
      .val(@defaultDescriptionFor(type))
      .trigger('autosize.resize')

  defaultDescriptionFor: (type)->
    switch type
      when '[feature]' then @FEATURE_DESCRIPTION
      when '[bug]' then @BUG_DESCRIPTION
      else ''
