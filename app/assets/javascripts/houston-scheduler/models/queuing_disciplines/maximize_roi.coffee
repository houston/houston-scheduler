window.Scheduler ?= {}
Scheduler.QueuingDiscipline ?= {}
Scheduler.QueuingDisciplines ?= []

class Scheduler.QueuingDiscipline.MaximizeRoi
  
  name: "Maximize ROI"
  
  sorter: (ticket)->
    priority = ticket.get('estimatedValue') / ticket.get('estimatedEffort')
    -priority


Scheduler.QueuingDisciplines.push new Scheduler.QueuingDiscipline.MaximizeRoi()
