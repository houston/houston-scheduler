class Scheduler.Router extends Backbone.Router

  routes:
    '':                   'showSequence'
    'sequence':           'showSequence'
    'unable-to-estimate': 'showUnableToEstimate'
    'postponed':          'showPostponed'
    'estimate-effort':    'showTicketsWithNoEffort'
    'estimate-value':     'showFeaturesWithNoValue'
    'estimate-severity':  'showBugsWithNoSeverity'
    'planning-poker':     'showPlanningPoker'
    'vision':             'showValueStatements'


  initialize: (options)->
    @parent = options.parent


  reload: ->
    location = window.location.hash.replace(/^#?\/?/, '').replace(/\?.*/, '')
    method = @routes[location]
    if method
      console.log "[router] refreshing #{location}"
      @[method]()
    else
      console.log "[router] unable to refresh #{location}"


  showSequence: ->
    @activateTab('#sequence')
    @show new Scheduler.SequenceView
      project: @parent.project
      tickets: @parent.ticketsReadyToPrioritize()
      velocity: @parent.velocity
      readonly: !@parent.canPrioritize

  showUnableToEstimate: ->
    @updateActiveTab()
    @show new Scheduler.UnableToEstimateView
      tickets: @parent.ticketsWaitingForDiscussion()
      canEstimate: @parent.canEstimate
      canPrioritize: @parent.canPrioritize

  showPostponed: ->
    @updateActiveTab()
    @show new Scheduler.PostponedView
      tickets: @parent.ticketsPostponed()
      canPrioritize: @parent.canPrioritize

  showTicketsWithNoEffort: ->
    @updateActiveTab()
    @show new Scheduler.EditTicketsEffortView
      project: @parent.project
      tickets: @parent.openTickets()

  showFeaturesWithNoValue: ->
    @updateActiveTab()
    @show new Scheduler.EditFeaturesValueView
      project: @parent.project
      tickets: @parent.openTickets().features()

  showBugsWithNoSeverity: ->
    @updateActiveTab()
    @show new Scheduler.EditBugsSeverityView
      project: @parent.project
      tickets: @parent.openTickets().bugs()

  showPlanningPoker: ->
    @updateActiveTab()
    @show new Scheduler.PlanningPoker
      tickets: @parent.ticketsWaitingForEffortEstimate()
      maintainers: @parent.maintainers

  showValueStatements: ->
    @updateActiveTab()
    @show new Scheduler.ValueStatementsView
      project: @parent.project



  show: (view)->
    @parent.showTab(view)

  updateActiveTab: ->
    @activateTab(window.location.hash)

  activateTab: (hash)->
    $('.active').removeClass('active')
    $("a[href=\"#{hash}\"]").parent().addClass('active')
