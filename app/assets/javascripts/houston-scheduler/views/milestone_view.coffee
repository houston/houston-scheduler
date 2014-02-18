class Scheduler.MilestoneView extends Backbone.View
  tagName: 'div'
  className: 'milestone'
  
  initialize: ->
    @milestone = @options.milestone
    @template = HandlebarsTemplates['houston-scheduler/milestones/milestone']
    @$el.attr('data-id', @milestone.id)
    @$el.on 'drop', (e, ui)=> @trigger('drop', ui.draggable)
    @$el.on 'click', '.milestone-close', (e)=>
      e.preventDefault()
      @close()
  
  render: ->
    html = @template
      name: @milestone.get('name')
      ticketsCount: @milestone.tickets.length
      complexity: @milestone.complexity()
      url: "/scheduler/milestones/#{@milestone.id}"
    @$el.html(html)
    @$el.droppable
      accept: '.sequence-ticket'
      activate: => @$el.parent().addClass('drag-activated')
      deactivate: => @$el.parent().removeClass('drag-activated'); @$el.removeClass('drag-over')
      over: => @$el.addClass('drag-over')
      out: => @$el.removeClass('drag-over')
  
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
    
  close: ->
    @milestone.destroy()
      .done => @remove()
