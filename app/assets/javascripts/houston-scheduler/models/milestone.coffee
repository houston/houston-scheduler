class Scheduler.Milestone extends Backbone.Model
  urlRoot: '/scheduler/milestones'

class Scheduler.Milestones extends Backbone.Collection
  model: Scheduler.Milestone
