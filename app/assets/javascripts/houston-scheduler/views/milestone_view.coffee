class Scheduler.MilestoneView extends Backbone.View
  tagName: 'div'
  className: 'milestone'
  
  initialize: ->
    @milestone = @options.milestone
    @template = HandlebarsTemplates['houston-scheduler/milestones/milestone']
  
  render: ->
    @$el.attr('data-id', @milestone.id)
    html = @template @milestone.toJSON()
    @$el.html(html)
