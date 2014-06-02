class Scheduler.EditFeaturesValueView extends Scheduler.EstimateTicketsView
  template: HandlebarsTemplates['houston-scheduler/tickets/edit_features_value']
  ticketsTemplate: HandlebarsTemplates['houston-scheduler/tickets/edit_features_value_tickets']
  taskView: Scheduler.EditFeatureValueView
  
  initialize: ->
    super
    @tickets = @incompleteTickets = @tickets.withoutValueEstimate(@project.valueStatements)
  
  ticketToJson: (ticket)->
    json = ticket.toJSON()
    json.value = ticket.contributionTo(@project.valueStatements)
    json.saved = ticket.valueEstimated(@project.valueStatements)
    json.value = if json.value > 0 then json.value.toFixed(1) else ''
    json
