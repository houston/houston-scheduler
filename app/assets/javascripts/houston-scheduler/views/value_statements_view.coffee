class Scheduler.ValueStatementsView extends Backbone.View
  
  events:
    'keydown #new_value_statement': 'onKeyDown'
    'click #update_value_statements': 'save'
    'click .delete-link': 'deleteValueStatement'
  
  initialize: ->
    @project = @options.project
    @template = HandlebarsTemplates['houston-scheduler/value_statements/index']
    @renderStatement = HandlebarsTemplates['houston-scheduler/value_statements/show']
    @statements = @project.valueStatements ? []
    @viewId = 0
    statement.viewId = ++@viewId for statement in @statements
  
  render: ->
    @$el.html @template
      project: @project
    @$statements = $('#value_statements')
    @appendStatement(statement) for statement in @statements
  
  appendStatement: (statement)->
    $(@renderStatement statement)
      .appendTo(@$statements)
      .find('.weight-throttle').slider
        range: "min"
        max: 100
        value: statement.weight,
        start: _.bind(@calculateMaxValueForSlider, @)
        slide: _.bind(@coercePercent, @)
        change: _.bind(@coercePercentOnChange, @)
  
  onKeyDown: (e)->
    if e.keyCode == 13
      @addValueStatement $(e.target).val()
      $(e.target).val('')
      e.preventDefault()
  
  
  
  addValueStatement: (text)->
    statement = 
      text: text
      weight: @newStatementWeight()
      viewId: ++@viewId
    @redistributeWeightsToFree(statement.weight)
    @appendStatement statement
    @statements.push statement
  
  deleteValueStatement: (e)->
    e.preventDefault()
    $statement = $(e.target).closest('.value-statement')
    viewId = +$statement.attr('data-id')
    statement = _.detect @statements, (statement)-> statement.viewId == viewId
    statement._destroy = true
    statement.weight = 0
    $statement.remove()
  
  
  
  newStatementWeight: ->
    Math.floor(100 / (@statements.length + 1))
    
  redistributeWeightsToFree: (weightNeeded)->
    weightFree = @calculateMaxValueForStatement(-1)
    return if weightNeeded <= weightFree
    
    scaleBy = (100 - weightNeeded) / (100 - weightFree)
    
    for statement in @statements
      statement.weight = Math.floor(statement.weight * scaleBy)
      $(".value-statement[data-id=#{statement.viewId}] .weight-throttle").slider('value', statement.weight)
  
  
  
  calculateMaxValueForSlider: (e, {handle})->
    $statement = $(handle).closest('.value-statement')
    viewId = +$statement.attr('data-id')
    @maxValueForSlider = @calculateMaxValueForStatement(viewId)

  calculateMaxValueForStatement: (viewId)->
    maxValue = 100
    maxValue -= statement.weight for statement in @statements when statement.viewId isnt viewId
    maxValue

  coercePercent: (e, {handle, value})->
    coerced = false

    if value > @maxValueForSlider
      value = @maxValueForSlider
      $(handle).closest('.ui-slider').slider('value', value)
      coerced = true

    $statement = $(handle).closest('.value-statement')
    viewId = +$statement.attr('data-id')
    statement = _.detect @statements, (statement)-> statement.viewId == viewId
    statement.weight = value

    $statement.find('.weight-percentage').html(value)

    !coerced

  coercePercentOnChange: (e, ui)->
    @calculateMaxValueForSlider(e, ui)
    @coercePercent(e, ui)
    true



  save: (e)->
    e.preventDefault()
    xhr = $.put "/scheduler/projects/#{@project.id}/value_statements",
      statements: _.map @statements, (statement)->
        id: statement.id
        text: statement.text
        weight: statement.weight
        _destroy: statement._destroy
    xhr.success ->
      $('.alert').remove()
      $('#body').prepend '<div class="alert alert-success">Changes saved <a class="close" data-dismiss="alert" href="#">&times;</a></div>'
    xhr.error (response)->
      $('.alert').remove()
      $('#body').prepend "<div class=\"alert alert-error\">#{response.responseText} <a class=\"close\" data-dismiss=\"alert\" href=\"#\">&times;</a></div>"

