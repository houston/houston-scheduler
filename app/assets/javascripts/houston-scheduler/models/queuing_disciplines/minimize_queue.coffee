window.Scheduler ?= {}
Scheduler.QueuingDiscipline ?= {}
Scheduler.QueuingDisciplines ?= []

class Scheduler.QueuingDiscipline.MinimizeQueue
  
  name: "Minimize Queue"
  
  sorter: (ticket)->
    ticket.get('estimatedEffort')


Scheduler.QueuingDisciplines.push new Scheduler.QueuingDiscipline.MinimizeQueue()
