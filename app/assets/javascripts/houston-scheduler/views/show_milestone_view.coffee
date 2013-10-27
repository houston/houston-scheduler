class Scheduler.ShowMilestoneView extends Backbone.View
  
  events:
    'click .btn-remove': 'removeTicket'
  
  initialize: ->
    @tickets = @options.tickets
    @template = HandlebarsTemplates['houston-scheduler/milestones/show']
    super
    @render()
  
  render: ->
    tickets = (ticket.toJSON() for ticket in @tickets)
    tickets = _.sortBy tickets, (ticket)-> ticket.summary
    html = @template(tickets: tickets)
    @$el.html html
    
    @renderBurndownChart(tickets)
    
    $('.table-sortable').tablesorter()
    @
  
  
  
  renderBurndownChart: (tickets)->
    
    # Sum progress by week;
    # Find the total amount of effort to accomplish
    progressBySprint = {}
    totalEffort = 0
    mostRecentDataPoint = 0
    for ticket in tickets
      effort = +ticket.estimatedEffort
      if ticket.firstReleaseAt
        firstReleaseAt = new Date(ticket.firstReleaseAt)
        mostRecentDataPoint = +firstReleaseAt if mostRecentDataPoint < firstReleaseAt
        sprint = @getEndOfSprint(firstReleaseAt)
        progressBySprint[sprint] = (progressBySprint[sprint] || 0) + effort
      totalEffort += effort
    
    [firstSprint, lastSprint] = d3.extent(+date for date in _.keys(progressBySprint))
    
    # Start 1 week before the first progress was made
    # to show the original total effort of the milestone
    firstSprint = @prevSprint(firstSprint)
    
    # Transform into remaining effort by week:
    # Iterate by week in case there are some weeks
    # where no progress was made
    remainingEffort = totalEffort
    sprint = firstSprint
    data = []
    while sprint <= lastSprint
      remainingEffort -= (progressBySprint[sprint] || 0)
      data.push
        sprint: sprint
        effort: Math.ceil(remainingEffort)
      sprint = @nextSprint(sprint)
    
    # If the most recent data point is for an incomplete
    # sprint, disregard it when calculating the regressions
    lastCompleteSprint = @getEndOfSprint(1.week().before(new Date()))
    if mostRecentDataPoint > lastCompleteSprint
      regAll   = @computeRegression(data.slice( 0, -1)) if data.length >= 6  # all time
      regLast3 = @computeRegression(data.slice(-5, -1)) if data.length >= 5  # last 3 weeks only
      regLast2 = @computeRegression(data.slice(-4, -1)) if data.length >= 4  # last 2 weeks only
    else
      regAll   = @computeRegression(data)               if data.length >= 5  # all time
      regLast3 = @computeRegression(data.slice(-4))     if data.length >= 4  # last 3 weeks only
      regLast2 = @computeRegression(data.slice(-3))     if data.length >= 3  # last 2 weeks only
    
    console.log 'mostRecentDataPoint', new Date(mostRecentDataPoint)
    console.log 'lastCompleteSprint', new Date(lastCompleteSprint)
    
    console.log 'regAll', new Date(regAll.x2) if regAll
    console.log 'regLast3', new Date(regLast3.x2) if regLast3
    console.log 'regLast2', new Date(regLast2.x2) if regLast2
    
    # Widen the graph so that it includes the X intercept
    projections = []
    projections.push regAll.x2 if regAll
    projections.push regLast2.x2 if regLast2
    projections.push regLast3.x2 if regLast3
    sprints = []
    if projectedEnd = projections.max()
      lastSprint = @getEndOfSprint(projectedEnd)
      sprints = (d.sprint for d in data).sort()
      sprint = _.last(sprints)
      while sprint < lastSprint
        sprint = @nextSprint(sprint)
        sprints.push(sprint)
    
    margin = {top: 40, right: 80, bottom: 32, left: 50}
    width = 960 - margin.left - margin.right
    height = 320 - margin.top - margin.bottom
    formatDate = d3.time.format('%b %e')
    
    x = d3.scale.ordinal().rangePoints([0, width], 0.75).domain(sprints)
    y = d3.scale.linear().range([height, 0]).domain([0, totalEffort])
    rx = d3.scale.linear()
      .range([x(firstSprint), x(lastSprint)])
      .domain([firstSprint, lastSprint])
    
    xAxis = d3.svg.axis()
      .scale(x)
      .orient('bottom')
      .tickFormat((d)-> formatDate(new Date(d)))
    
    yAxis = d3.svg.axis()
      .scale(y)
      .orient('left')
    
    line = d3.svg.line()
      .interpolate('cardinal')
      .x((d)-> x(d.sprint))
      .y((d)-> y(d.effort))
    
    svg = d3.select('#graph').append('svg')
        .attr('width', width + margin.left + margin.right)
        .attr('height', height + margin.top + margin.bottom)
      .append('g')
        .attr('transform', "translate(#{margin.left},#{margin.top})")
    
    svg.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{height})")
      .call(xAxis)
    
    svg.append('g')
        .attr('class', 'y axis')
        .call(yAxis)
      .append('text')
        .attr('transform', 'rotate(-90)')
        .attr('y', -45)
        .attr('x', -160)
        .attr('dy', '.71em')
        .attr('class', 'legend')
        .style('text-anchor', 'end')
        .text('Points Remaining')
    
    if regAll
      svg.append('line')
        .attr('class', 'regression regression-all')
        .attr('x1', rx(regAll.x1))
        .attr('y1', y(regAll.y1))
        .attr('x2', rx(regAll.x2))
        .attr('y2', y(regAll.y2))
    
    if regLast2
      svg.append('line')
        .attr('class', 'regression regression-last-2')
        .attr('x1', rx(regLast2.x1))
        .attr('y1', y(regLast2.y1))
        .attr('x2', rx(regLast2.x2))
        .attr('y2', y(regLast2.y2))
    
    if regLast3
      svg.append('line')
        .attr('class', 'regression regression-last-3')
        .attr('x1', rx(regLast3.x1))
        .attr('y1', y(regLast3.y1))
        .attr('x2', rx(regLast3.x2))
        .attr('y2', y(regLast3.y2))
    
    svg.append('path')
      .attr('class', 'line')
      .attr('d', line(data))
    
    svg.selectAll('circle')
      .data(data)
      .enter()
      .append('circle')
        .attr('r', 5)
        .attr('cx', (d)-> x(d.sprint))
        .attr('cy', (d)-> y(d.effort))
    
    svg.selectAll('.effort-remaining')
      .data(data)
      .enter()
      .append('text')
        .text((d) -> d.effort)
        .attr('class', 'effort-remaining')
        .attr('transform', (d)-> "translate(#{x(d.sprint) + 5.5}, #{y(d.effort) - 10}) rotate(-75)")
    
    insertLinebreaks = (d)->
      el = d3.select(this)
      words = el.text().split(/\s+/)
      el.text('')
      
      el.append('tspan').text(words[0]).attr('class', 'month')
      el.append('tspan').text(words[1]).attr('x', 0).attr('dy', '11').attr('class', 'day')
    
    svg.selectAll('.x.axis text').each(insertLinebreaks)
  
  prevSprint: (timestamp)->
    1.week().before(new Date(timestamp)).getTime()
  
  nextSprint: (timestamp)->
    1.week().after(new Date(timestamp)).getTime()
  
  getEndOfSprint: (timestamp)->
    +@getNextFriday(new Date(timestamp))
  
  getNextFriday: (date)->
    wday = date.getDay() # 0-6 (0=Sunday)
    daysUntilFriday = 5 - wday # 5=Friday
    daysUntilFriday += 7 if daysUntilFriday < 0
    daysUntilFriday.days().after(date)
  
  computeRegression: (data)->
    # Compute the linear regression of the points
    # http://trentrichardson.com/2010/04/06/compute-linear-regressions-in-javascript/
    # http://dracoblue.net/dev/linear-least-squares-in-javascript/159/
    [sum_x, sum_y, sum_xx, sum_xy, n] = [0, 0, 0, 0, data.length]
    for d in data
      [_x, _y] = [d.sprint, d.effort]
      sum_x += _x
      sum_y += _y
      sum_xx += _x * _x
      sum_xy += _x * _y
    m = (n*sum_xy - sum_x*sum_y) / (n*sum_xx - sum_x*sum_x)
    b = (sum_y - m*sum_x)/n
    
    # No progress is being made
    return null if m == 0
    
    # Find the X intercept
    [x0, y0] = [((0 - b) / m), 0]
    
    # Calculate the regression line
    x1: data[0].sprint
    x2: x0
    y1: b + m * data[0].sprint
    y2: y0
  
  
  
  removeTicket: (e)->
    e.preventDefault()
    
    $ticket = $(e.target).closest('.ticket')
    id = +$ticket.attr('data-ticket-id')
    ticket = _.find @tickets, (ticket)-> ticket.id is id
    
    attributes =
      milestoneId: null
    
    $button = $ticket.find('button')
    $ticket.addClass 'working'
    $button.attr('disabled', 'disabled')
    ticket.save attributes,
      success: =>
        $ticket.remove()
      error: =>
        console.log arguments
        $ticket.removeClass 'working'
        $button.removeAttr('disabled', 'disabled')
