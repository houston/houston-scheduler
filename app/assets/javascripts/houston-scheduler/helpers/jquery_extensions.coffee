$.fn.extend
  
  appendView: (view)->
    @.append(view.el)
    view.render()
    @
  
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
