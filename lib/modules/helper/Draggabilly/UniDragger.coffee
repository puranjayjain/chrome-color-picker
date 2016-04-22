Unipointer = require './Unipointer'

###!
# Unidragger v2.1.0
# Draggable base class
# MIT license
###

module.exports =
# inherit Unipointer & EvEmitter
class Unidragger extends Unipointer

  constructor: (args) ->
    # body...

  # ----- bind start ----- //
  # -----  ----- //

  noop = ->

  # -------------------------- Unidragger -------------------------- //

  bindHandles: ->
    @_bindHandles true
    return

  unbindHandles: ->
    @_bindHandles false
    return

  navigator = window.navigator

  ###*
  # works as unbinder, as you can .bindHandles( false ) to unbind
  # @param {Boolean} isBind - will unbind if falsey
  ###

  _bindHandles: (isBind) ->
    # munge isBind, default to true
    isBind = if isBind is undefined then true else ! !isBind
    # extra bind logic
    binderExtra = undefined
    if navigator.pointerEnabled
      binderExtra: (handle) ->
        # disable scrolling on the element
        handle.style.touchAction = if isBind then 'none' else ''
        return
    else
      binderExtra = noop
    # bind each handle
    bindMethod = if isBind then 'addEventListener' else 'removeEventListener'
    i = 0
    while i < @handles.length
      handle = @handles[i]
      @_bindStartEvent handle, isBind
      binderExtra handle
      handle[bindMethod] 'click', @
      i++
    return

  # ----- start event ----- //

  ###*
  # pointer start
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  pointerDown: (event, pointer) ->
    # dismiss range sliders
    if event.target.nodeName is 'INPUT' and event.target.type is 'range'
      # reset pointerDown logic
      @isPointerDown = false
      delete @pointerIdentifier
      return
    @_dragPointerDown event, pointer
    # kludge to blur focused inputs in dragger
    focused = document.activeElement
    if focused and focused.blur
      focused.blur()
    # bind move and end events
    @_bindPostStartEvents event
    @emitEvent 'pointerDown', [
      event
      pointer
    ]
    return

  # base pointer down logic

  _dragPointerDown: (event, pointer) ->
    # track to see when dragging starts
    @pointerDownPoint = Unipointer.getPointerPoint(pointer)
    canPreventDefault = @canPreventDefaultOnPointerDown(event, pointer)
    if canPreventDefault
      event.preventDefault()
    return

  # overwriteable method so Flickity can prevent for scrolling

  canPreventDefaultOnPointerDown: (event) ->
    # prevent default, unless touchstart or <select>
    event.target.nodeName isnt 'SELECT'

  # ----- move event ----- //

  ###*
  # drag move
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  pointerMove: (event, pointer) ->
    moveVector = @_dragPointerMove(event, pointer)
    @emitEvent 'pointerMove', [
      event
      pointer
      moveVector
    ]
    @_dragMove event, pointer, moveVector
    return

  # base pointer move logic

  _dragPointerMove: (event, pointer) ->
    movePoint = Unipointer.getPointerPoint(pointer)
    moveVector =
      x: movePoint.x - (@pointerDownPoint.x)
      y: movePoint.y - (@pointerDownPoint.y)
    # start drag if pointer has moved far enough to start drag
    if not @isDragging and @hasDragStarted(moveVector)
      @_dragStart event, pointer
    moveVector

  # condition if pointer has moved far enough to start drag

  hasDragStarted: (moveVector) ->
    Math.abs(moveVector.x) > 3 or Math.abs(moveVector.y) > 3

  # ----- end event ----- //

  ###*
  # pointer up
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  pointerUp: (event, pointer) ->
    @emitEvent 'pointerUp', [
      event
      pointer
    ]
    @_dragPointerUp event, pointer
    return

  _dragPointerUp: (event, pointer) ->
    if @isDragging
      @_dragEnd event, pointer
    else
      # pointer didn't move enough for drag to start
      @_staticClick event, pointer
    return

  # -------------------------- drag -------------------------- //
  # dragStart

  _dragStart: (event, pointer) ->
    @isDragging = true
    @dragStartPoint = Unipointer.getPointerPoint(pointer)
    # prevent clicks
    @isPreventingClicks = true
    @dragStart event, pointer
    return

  dragStart: (event, pointer) ->
    @emitEvent 'dragStart', [
      event
      pointer
    ]
    return

  # dragMove

  _dragMove: (event, pointer, moveVector) ->
    # do not drag if not dragging yet
    if not @isDragging
      return
    @dragMove event, pointer, moveVector
    return

  dragMove: (event, pointer, moveVector) ->
    event.preventDefault()
    @emitEvent 'dragMove', [
      event
      pointer
      moveVector
    ]
    return

  # dragEnd

  _dragEnd: (event, pointer) ->
    # set flags
    @isDragging = false
    # re-enable clicking async
    setTimeout (->
      delete @isPreventingClicks
      return
    ).bind(@)
    @dragEnd event, pointer
    return

  dragEnd: (event, pointer) ->
    @emitEvent 'dragEnd', [
      event
      pointer
    ]
    return

  # ----- onclick ----- //
  # handle all clicks and prevent clicks when dragging

  onclick: (event) ->
    if @isPreventingClicks
      event.preventDefault()
    return

  # ----- staticClick ----- //
  # triggered after pointer down & up with no/tiny movement

  _staticClick: (event, pointer) ->
    # ignore emulated mouse up clicks
    if @isIgnoringMouseUp and event.type is 'mouseup'
      return
    # allow click in <input>s and <textarea>s
    nodeName = event.target.nodeName
    if nodeName is 'INPUT' or nodeName is 'TEXTAREA'
      event.target.focus()
    @staticClick event, pointer
    # set flag for emulated clicks 300ms after touchend
    if event.type isnt 'mouseup'
      @isIgnoringMouseUp = true
      # reset flag after 300ms
      setTimeout (->
        delete @isIgnoringMouseUp
        return
      ).bind(@), 400
    return

  staticClick: (event, pointer) ->
    @emitEvent 'staticClick', [
      event
      pointer
    ]
    return

  # ----- utils ----- //
  Unidragger.getPointerPoint = Unipointer.getPointerPoint
  # -----  ----- //
  Unidragger
