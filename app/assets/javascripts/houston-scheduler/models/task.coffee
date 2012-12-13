class window.Task extends Backbone.Model
  
  priority: ->
    @get('value') / @get('effort')

class window.Tasks extends Backbone.Collection
  model: Task
  
  sortByPriority: ->
    @sortBy (task)-> -task.priority()
