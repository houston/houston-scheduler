$.fn.extend
  
  cssHover: (selector)->
    if arguments.length == 0
      @hover(
        -> $(@).addClass('hovered'),
        -> $(@).removeClass('hovered'))
    else
      @delegate selector, 'hover', (e)->
        if e.type == 'mouseenter'
          $(@).addClass('hovered')
        else
          $(@).removeClass('hovered')
  
  serializeFormElements: ->
    data = {}
    @find('input, select, textarea').each ->
      elem = $(@)
      elemType = elem.attr('type')
      name = elem.attr('name')
      if elemType == 'checkbox' || elemType == 'radio'
        data[name] = '' if _.isUndefined(data[name])
        data[name] = elem.val() if elem.is(':checked')
      else
        data[name] = elem.val()
    data
  
  positionAbsolutely: ->
    positions = ($(el).position() for el in @)
    for i in [0...@length]
      $el = $(@[i])
      pos = positions[i]
      $el.css
        position: 'absolute'
        top: pos.top
        left: pos.left
        width: $el.width()
        height: $el.height()
  
  loadTicketDetailsOnClick: ->
    $(@).delegate '.ticket-details', 'click', (e)->
      e.preventDefault()
      e.stopImmediatePropagation()
      url = $(e.target).attr('href')
      $.get url, (ticket)->
        html = """
        <div class="modal hide fade">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h3>Description</h3>
          </div>
          <div class="modal-body">
            #{ticket.description}
          </div>
        </div>
        """
        $(html).modal()
