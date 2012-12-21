Scheduler.QueuingDiscipline ?= {}
Scheduler.QueuingDisciplines ?= []

class Scheduler.QueuingDiscipline.MinimizeQueue
  
  name: "Minimize Queue"
  
  sorter: (ticket)->
    ticket.get('estimated_effort')


Scheduler.QueuingDisciplines.push new Scheduler.QueuingDiscipline.MinimizeQueue()
