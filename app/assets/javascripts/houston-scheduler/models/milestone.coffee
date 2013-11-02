class Scheduler.Milestone extends Backbone.Model
  urlRoot: '/scheduler/milestones'
  
  constructor: ->
    super
    @tickets = []
  
  complexity: ->
    complexity = 0
    indeterminate = false
    for ticket in @tickets
      effort = ticket.get('estimatedEffort')
      if effort > 0
        complexity += +effort
      else
        indeterminate = true
    
    complexity = Math.ceil(complexity)
    complexity += '+' if indeterminate
    complexity

class Scheduler.Milestones extends Backbone.Collection
  model: Scheduler.Milestone
