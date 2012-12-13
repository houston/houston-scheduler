class window.TasksView extends Backbone.View
  
  events:
    'click #sort_tasks': 'sortByPriority'
    'change #resources_count': 'updateWipConstraint'
  
  initialize: ->
    @tasks = @options.tasks
    @wip = 3
  
  sortedTasks: ->
    @tasks.sortByPriority()
  
  render: ->
    template = HandlebarsTemplates['houston-scheduler/tasks/index']
    $(@el).html template()
    
    @renderTasks()
    @renderSchedule()
    @
  
  renderTasks: ->
    $ul = $('#tasks')
    $ul.empty()
    for task in @sortedTasks()
      $ul.appendView(new TaskView(task: task))
  
  renderSchedule: ->
    $schedule = $('#schedule')
    $schedule.empty()
    
    @tasks.each (task)->
      color = projects[task.get('project')]
      $schedule.append "<div class=\"scheduled-task\" data-cid=\"#{task.cid}\" style=\"background-color: #{color}\"></div>"
    
    @updateSchedule()
  
  
  
  updateWipConstraint: ->
    @wip = +$('#resources_count').val()
    @updateSchedule()
  
  updateSchedule: ->
    tasks = @sortedTasks()
    numberOfRows = @wip
    rows = (new Row(i) for i in [1..numberOfRows])
    
    positionByCID = {}
    for task in tasks
      shortestRow = _.min rows, (row)-> row.width()
      positionByCID[task.cid] =
        width: +task.get('effort')
        y: shortestRow.index
        x: shortestRow.width()
      shortestRow.addTask(task)
    
    maxWidth = (_.max rows, (row)-> row.width()).width()
    
    $('#schedule_axis').html("#{maxWidth} hours")
    
    # $.clear()
    
    $('#schedule').tween
      height: 
        stop: @wip * 22
        duration: 0.50
        effect: 'quadInOut'
    
    for cid, position of positionByCID
      widthPercent = position.width / maxWidth * 100
      leftPercent = position.x / maxWidth * 100
      top = (position.y - 1) * 22
      
      $(".scheduled-task[data-cid=#{cid}]").tween
        left:
          stop: "#{leftPercent}%"
          duration: 0.50
          effect: 'quadInOut'
        width:
          stop: "#{widthPercent}%"
          duration: 0.50
          effect: 'quadInOut'
        top:
          stop: top
          duration: 0.50
          effect: 'quadInOut'
    
    $.play()
  
  
  sortByPriority: ->
    sortedTasks = @tasks.sortByPriority()
    
    positionByCID = {}
    for pos in [0...sortedTasks.length]
      task = sortedTasks[pos]
      positionByCID[task.cid] = pos
    
    @animateTasksToPositions
      duration: 0.50
      easing: 'quadInOut'
      positionByCID: positionByCID
      onComplete: _.bind(@renderTasks, @)
  
  animateTasksToPositions: (options)->
    duration      = options.duration
    easing        = options.easing
    positionByCID = options.positionByCID
    onComplete    = options.onComplete
    
    $el = $(@el)
    $tasks = $el.find('.task')
    taskHeight = 38
    
    $('#tasks').css(height: $('#tasks').height())
    $tasks.positionAbsolutely()
    
    $.clear()
    
    for pos in [0...$tasks.length]
      $task = $($tasks[pos])
      
      cid = $task.attr('data-cid')
      newPosition = positionByCID[cid]
      
      unless pos == newPosition
        newTop = newPosition * taskHeight
        params = 
          top:
            start: $task.position().top
            stop: newTop
            duration: duration
            effect: easing
        $task.tween(params)
    
    $.play =>
      $('#tasks').css(height: '')
      @updateSchedule()
      onComplete()


class Row
  
  constructor: (index)->
    @index = index
    @tasks = []
  
  addTask: (task)->
    @tasks.push task
  
  width: ->
    _.reduce @tasks, ((sum, task)-> sum + +task.get('effort')), 0

