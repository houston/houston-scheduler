window.Scheduler =
  
  loadTicketDetails: (url, callback)->
    return unless url
    $.get url, (ticket)->
      html = """
      <div class="modal hide" tabindex="-1">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
          <h3>#{ticket.summary}</h3>
        </div>
        <div class="modal-body">
          #{ticket.description}
        </div>
      </div>
      """
      $modal = $(html).modal()
      $modal.on('hidden', callback) if callback
    
$.tablesorter.addParser
  id: 'inputs'
  is: (s)-> false # don't auto-detect
  format: (text, table, td)->
    $(td).find('input').val()
  type: 'numeric'

$.tablesorter.addParser
  id: 'timestamp'
  is: (s)-> false # don't auto-detect
  format: (text, table, td)-> $(td).attr('data-timestamp')
  type: 'text'

$.tablesorter.addParser
  id: 'sequence'
  is: (s)-> false # don't auto-detect
  format: (text, table, td)->
    i = +text
    return 1/0 if i <= 0 # i.e. invalid
    i
  type: 'numeric'
