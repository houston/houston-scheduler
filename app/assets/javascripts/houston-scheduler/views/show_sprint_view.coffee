class Scheduler.ShowSprintView extends Backbone.View
  
  events:
    'click .check-out-button': 'toggleCheckOut'
  
  initialize: ->
    @sprintId = @options.sprintId
    @template = HandlebarsTemplates['houston-scheduler/sprints/show']
    
    $.get "/scheduler/sprints/#{@sprintId}", (tickets)=>
      for ticket in tickets
        ticket.checkedOut = ticket.checkedOutBy?
        ticket.checkedOutByMe = ticket.checkedOutBy && ticket.checkedOutBy.id == window.user.id
      @tickets = tickets
      @render()
    
    super
  
  render: ->
    return @ unless @tickets
    html = @template(tickets: @tickets)
    @$el.html html
    
    @renderBurndownChart(@tickets)
    
    $('.table-sortable').tablesorter()
    @
  
  
  
  renderBurndownChart: (tickets)->
    
    # Sum progress by day;
    # Find the total amount of effort to accomplish
    progressByDay = {}
    totalEffort = 0
    for ticket in tickets
      effort = +ticket.estimatedEffort
      if ticket.firstReleaseAt
        day = @truncateDate new Date(ticket.firstReleaseAt)
        progressByDay[day] = (progressByDay[day] || 0) + effort
      totalEffort += effort
    
    thisWeek = []
    today = new Date()
    daysSinceMonday = 1 - today.getWeekday() 
    monday = @truncateDate daysSinceMonday.days().after(today)
    days = (i.days().after(monday) for i in [0..4])
    
    # Transform into remaining effort by day:
    # Iterate by day in case there are some days
    # where no progress was made
    remainingEffort = totalEffort - (progressByDay[monday] || 0)
    data = [
      day: monday
      effort: Math.ceil(remainingEffort)
    ]
    for day in days.slice(1)
      unless day > today
        remainingEffort -= (progressByDay[day] || 0)
        data.push
          day: day
          effort: Math.ceil(remainingEffort)
    
    margin = {top: 40, right: 80, bottom: 32, left: 50}
    width = 960 - margin.left - margin.right
    height = 320 - margin.top - margin.bottom
    formatDate = d3.time.format('%A')
    
    x = d3.scale.ordinal().rangePoints([0, width], 0.75).domain(days)
    y = d3.scale.linear().range([height, 0]).domain([0, totalEffort])
    
    xAxis = d3.svg.axis()
      .scale(x)
      .orient('bottom')
      .tickFormat((d)-> formatDate(new Date(d)))
    
    yAxis = d3.svg.axis()
      .scale(y)
      .orient('left')
    
    line = d3.svg.line()
      .interpolate('cardinal')
      .x((d)-> x(d.day))
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
    
    svg.append('path')
      .attr('class', 'line')
      .attr('d', line(data))
    
    svg.selectAll('circle')
      .data(data)
      .enter()
      .append('circle')
        .attr('r', 5)
        .attr('cx', (d)-> x(d.day))
        .attr('cy', (d)-> y(d.effort))
    
    svg.selectAll('.effort-remaining')
      .data(data)
      .enter()
      .append('text')
        .text((d) -> d.effort)
        .attr('class', 'effort-remaining')
        .attr('transform', (d)-> "translate(#{x(d.day) + 5.5}, #{y(d.effort) - 10}) rotate(-75)")
  
  truncateDate: (date)->
    date.setHours(0)
    date.setMinutes(0)
    date.setSeconds(0)
    date.setMilliseconds(0)
    date
  
  
  
  toggleCheckOut: (e)->
    $button = $(e.target)
    $ticket = $button.closest('tr')
    id = +$ticket.attr('data-ticket-id')
    ticket = _.find @tickets, (ticket)-> ticket.id == id
    
    if $button.hasClass('active')
      @checkIn($button, $ticket, id, ticket)
    else
      @checkOut($button, $ticket, id, ticket)
  
  checkIn: ($button, $ticket, id, ticket)->
    $.destroy("/scheduler/tickets/#{id}/lock")
      .success =>
        ticket.checkedOutAt = null
        ticket.checkedOutBy = null
      .error (xhr)=>
        errors = Errors.fromResponse(response)
        errors.renderToAlert().appendAsAlert()
  
  checkOut: ($button, $ticket, id, ticket)->
    $.post("/scheduler/tickets/#{id}/lock")
      .success =>
        ticket.checkedOutAt = new Date()
        ticket.checkedOutBy =
          id: window.user.id
          name: window.user.get('name')
          email: window.user.get('email')
      .error (response)=>
        errors = Errors.fromResponse(response)
        errors.renderToAlert().appendAsAlert()
