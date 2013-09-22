class Scheduler.MilestoneView extends Backbone.View
  tagName: 'div'
  className: 'milestone'
  
  initialize: ->
    @milestone = @options.milestone
    @template = HandlebarsTemplates['houston-scheduler/milestones/milestone']
    @$el.attr('data-id', @milestone.id)
    @$el.on 'drop', (e, ui)=> @trigger('drop', ui.draggable)
  
  render: ->
    html = @template
      name: @milestone.get('name')
      ticketsCount: @milestone.tickets.length
      complexity: @milestone.complexity()
      url: "/scheduler/milestones/#{@milestone.id}"
    @$el.html(html)
    @$el.droppable
      accept: '.sequence-ticket'
  
  addTicket: (ticket)->
    @$el.addClass 'working'
    ticket.save milestoneId: @milestone.id,
      patch: true
      success: =>
        @$el.removeClass('working')
      error: =>
        console.log arguments
        @$el.removeClass 'working'
      complete: =>
        @$el.removeClass 'working'
    @milestone.tickets.push ticket
    @render()
