window.Scheduler = {}

$.tablesorter.addParser
  id: 'inputs'
  is: (s)-> false # don't auto-detect
  format: (text, table, td)->
    $(td).find('input').val()
  type: 'numeric'

$.tablesorter.addParser
  id: 'sequence'
  is: (s)-> false # don't auto-detect
  format: (text, table, td)->
    i = +text
    return 1/0 if i <= 0 # i.e. invalid
    i
  type: 'numeric'
