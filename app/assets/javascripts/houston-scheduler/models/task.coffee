class Scheduler.Task extends Backbone.Model
  urlRoot: '/scheduler/tasks'
  
  
  
class Scheduler.Tasks extends Backbone.Collection
  model: Scheduler.Task
