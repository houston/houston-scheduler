Scheduler.QueuingDiscipline ?= {}
Scheduler.QueuingDisciplines ?= []

class Scheduler.QueuingDiscipline.Random
  
  name: "Random"
  
  sorter: (ticket)->
    Math.random()


Scheduler.QueuingDisciplines.push new Scheduler.QueuingDiscipline.Random()
