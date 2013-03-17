window.Scheduler ?= {}
Scheduler.QueuingDiscipline ?= {}
Scheduler.QueuingDisciplines ?= []

class Scheduler.QueuingDiscipline.MaximizeRoi
  
  name: "Maximize ROI"
  
  sorter: (ticket)->
    priority = ticket.get('estimated_value') / ticket.get('estimated_effort')
    -priority


Scheduler.QueuingDisciplines.push new Scheduler.QueuingDiscipline.MaximizeRoi()
