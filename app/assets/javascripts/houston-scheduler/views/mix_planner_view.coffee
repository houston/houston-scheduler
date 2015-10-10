class Scheduler.MixPlannerView extends Backbone.View

  initialize: ->
    @projects = @options.projects
    @readonly = @options.readonly
    @mixes = @options.mixes
    @formatDate = d3.time.format('%Y-%m-%d')
    @parseDate = @formatDate.parse
    @formatWeek = d3.time.format('%b %e')
    @formatWeekFull = d3.time.format('%B %e, %Y')
    @unparsedWeeks = _.keys(@mixes)
    @weeks = _.map(@unparsedWeeks, (week)=> @parseDate(week))
    @currentWeek = null

    @mixerView = new Scheduler.MixerView(projects: @projects, readonly: @readonly)
    @mixerView.bind 'change', _.bind(@refreshMix, @)

    $('#reset_mixes').click _.bind(@reset, @)
    $('#save_mixes').click _.bind(@save, @)

    @$el = $('#mixes_by_week')
    @el = @$el[0]

    @render()

    window.location.hash = @options.defaultMix unless window.location.hash
    Backbone.history.route /\d\d\d\d\-\d\d\-\d\d/, _.bind(@editMixFor, @)
    Backbone.history.start()

  render: ->
    margin = {top: 0, right: 0, bottom: 0, left: 0}
    @width = 960 - margin.left - margin.right
    @height = 120 - margin.top - margin.bottom

    @svg = d3.select('#mixes_graph').append('svg')
        .attr('width', @width + margin.left + margin.right)
        .attr('height', @height + margin.top + margin.bottom)
      .append('g')
        .attr('transform', "translate(#{margin.left},#{margin.top})")

    # @svg.append("g")
    #   .attr("class", "x axis")
    #   .attr("transform", "translate(0,#{@height})")

    x = d3.time.scale()
      .range([0, @width])
      .domain(d3.extent(@weeks))

    y = d3.scale.linear()
      .range([@height, 0]) # flip and project
      .domain([0, 100]) # values add up to 100%

    @color = d3.scale.ordinal()
      .range(project.hex for project in @projects)

    # xAxis = d3.svg.axis()
    #   .scale(x)
    #   .orient("bottom")
    #   .ticks(d3.time.days)

    @stack = d3.layout.stack()
      .offset("zero")
      .values((d)-> d.values)
      .x((d)-> d.date)
      .y((d)-> d.value)

    @nest = d3.nest()
      .key((d)-> d.key)

    window.area = @area = d3.svg.area()
      .interpolate("monotone")
      .x((d)-> x(d.date))
      .y0((d)-> y(d.y0))
      .y1((d)-> y(d.y0 + d.y))

    # @svg.select('.x.axis').call(xAxis)

    @renderMixesGraph()

    for week in @weeks
      @$el.append("<a class=\"mixer-mix\" href=\"##{@formatDate(week)}\">#{@formatWeek(week)}</a>")

  editMixFor: (week)->
    @currentWeek = week
    $('a.selected').removeClass('selected')
    $a = $("a[href=\"##{week}\"]").addClass('selected')
    $('#selected_week').html @formatWeekFull(@parseDate(week))
    @mixerView.loadMix @getMixFor(week)

  interpolatedMixes: ->
    mixes = {}
    lastSpecifiedMix = {}
    for week in @unparsedWeeks
      mix = _.clone(@mixes[week] ? {})
      if _.keys(mix).length > 0
        lastSpecifiedMix = mix
      else
        mix = _.clone(lastSpecifiedMix)
      mixes[week] = mix
    mixes

  getMixFor: (week)->
    @interpolatedMixes()[week]

  refreshMix: (mix)->
    return unless @currentWeek
    @mixes[@currentWeek] = mix
    @renderMixesGraph()

  renderMixesGraph: ->
    data = []
    for project in @projects
      values = []
      for week in @unparsedWeeks
        mix = @getMixFor(week)
        values.push
          date: @parseDate(week)
          value: mix[project.id.toString()] ? 0
      data.push
        key: project.name
        values: values

    graph = @svg.selectAll(".layer")
      .data(@stack(data))

    graph.enter().append("path")
      .attr("class", "layer")
      .attr("d", (d)=> @area(d.values) )
      .style("fill", (d, i)=> @color(i) )

    graph.transition().duration(200)
      .attr("d", (d)=> @area(d.values) )
      .style("fill", (d, i)=> @color(i) )



  reset: (e)->
    e.preventDefault()
    window.location.reload()

  save: (e)->
    e.preventDefault()

    $save = $(e.target)
    $save.attr('disabled', 'disabled').html('<i class="fa fa-spinner fa-spin"></i> Saving...')

    $.put('/scheduler/mixer', {mixes: @mixes})
      .success =>
        $('.alert').remove()
        $('#body').prepend '<div class="alert alert-success">Changes saved <a class="close" data-dismiss="alert" href="#">&times;</a></div>'
      .error (jqXhr)=>
        console.log(jqXhr) if console?.log
        $('.alert').remove()
        messsage = if jqXhr.status is 401 then "You are not authorized to make changes to project quotas" else "An error occurred"
        $('#body').prepend "<div class=\"alert alert-error\">#{messsage} <a class=\"close\" data-dismiss=\"alert\" href=\"#\">&times;</a></div>"
      .complete =>
        $save.removeAttr('disabled').html('Save')
