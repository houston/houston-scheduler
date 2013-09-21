class Scheduler.MilestonesView extends Backbone.View
  
  events:
    'click #new_milestone': 'newMilestone'
    'submit #new_milestone_form': 'createMilestone'
    'click #cancel_new_milestone_button': 'resetNewMilestone'
  
  initialize: ->
    @project = @options.project
    @milestones = @options.milestones
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/milestones/index']
    html = template()
    @$el.html(html)
    
    @renderMilestones()
  
  renderMilestones: ->
    $milestones = @$el.find('#milestones')
    $milestones.empty()
    $milestones.appendView @milestoneView(milestone) for milestone in @milestones.models
  
  newMilestone: ->
    $('#new_milestone').hide()
    $('#new_milestone_form').show()
    $('#new_milestone_name').select()
  
  createMilestone: (e)->
    e.preventDefault()
    $('#new_milestone_form').disable()
    attributes = 
      name: $('#new_milestone_name').val()
      projectId: @project.id
    @milestones.create attributes,
      wait: true
      success: (milestone)=>
        @$el.find('#milestones').appendView @milestoneView(milestone)
        @resetNewMilestone()
      error: (milestone, jqXhr)=>
        $('#new_milestone_form').enable()
        console.log('error', arguments)
        alert(jqXhr.responseText)
  
  milestoneView: (milestone)->
    new Scheduler.MilestoneView(milestone: milestone)
  
  resetNewMilestone: ->
    $('#new_milestone').show()
    $('#new_milestone_form').enable().hide()
    $('#new_milestone_name').val('')
