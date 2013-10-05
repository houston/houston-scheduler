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
    for ticket in tickets
      effort = +ticket.estimatedEffort
      if ticket.firstReleaseAt
        sprint = @getEndOfSprint(ticket.firstReleaseAt)
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
        effort: remainingEffort
      sprint = @nextSprint(sprint)
    
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
    
    # Find the X intercept
    [x0, y0] = [((0 - b) / m), 0]
    
    # Calculate the regression line
    lastSprint = @getEndOfSprint(x0)
    rx1 = firstSprint
    rx2 = x0
    ry1 = b + m * rx1
    ry2 = y0
    
    # Widen the graph so that it includes the X intercept
    sprints = (d.sprint for d in data).sort()
    sprint = _.last(sprints)
    while sprint < lastSprint
      sprint = @nextSprint(sprint)
      sprints.push(sprint)
    
    margin = {top: 40, right: 80, bottom: 24, left: 50}
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
        .attr('y', 6)
        .attr('dy', '.71em')
        .attr('class', 'legend')
        .style('text-anchor', 'end')
        .text('Points Remaining')
    
    svg.append('line')
      .attr('class', 'regression')
      .attr('x1', rx(rx1))
      .attr('y1', y(ry1))
      .attr('x2', rx(rx2))
      .attr('y2', y(ry2))
    
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
    
    svg.selectAll('.label')
      .data(data)
      .enter()
      .append('text')
        .text((d) -> d.effort)
        .attr('class', 'label')
        .attr('transform', (d)-> "translate(#{x(d.sprint) + 4.5}, #{y(d.effort) - 11}) rotate(-90)")
  
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
