EvEmitter = require('./EvEmitter')

###!
# Unipointer v2.1.0
# base class for doing one thing with pointer event
# MIT license
###

module.exports =
class Unipointer extends EvEmitter
  noop: ->

  bindStartEvent: (elem) ->
    @_bindStartEvent elem, true
    return

  unbindStartEvent: (elem) ->
    @_bindStartEvent elem, false
    return

  ###*
  # works as unbinder, as you can ._bindStart( false ) to unbind
  # @param {Boolean} isBind - will unbind if falsey
  ###
  _bindStartEvent: (elem, isBind) ->
    # munge isBind, default to true
    isBind = if isBind is undefined then true else not  not isBind
    bindMethod = if isBind then 'addEventListener' else 'removeEventListener'
    # listen for both, for devices like Chrome Pixel
    elem[bindMethod] 'mousedown', @
    elem[bindMethod] 'touchstart', @
    return

  # trigger handler methods for events
  handleEvent: (event) ->
    method = 'on' + event.type
    if @[method]
      @[method] event
    return

  # returns the touch that we're keeping track of
  getTouch: (touches) ->
    i = 0
    while i < touches.length
      touch = touches[i]
      if touch.identifier is @pointerIdentifier
        return touch
      i++
    return

  # ----- start event ----- //
  onmousedown: (event) ->
    # dismiss clicks from right or middle buttons
    button = event.button
    if button and button isnt 0 and button isnt 1
      return
    @_pointerDown event, event
    return

  ontouchstart: (event) ->
    @_pointerDown event, event.changedTouches[0]
    return

  onpointerdown: (event) ->
    @_pointerDown event, event
    return

  ###*
  # pointer start
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###
  _pointerDown: (event, pointer) ->
    # dismiss other pointers
    if @isPointerDown
      return
    @isPointerDown = true
    # save pointer identifier to match up touch events
    @pointerIdentifier = if pointer.pointerId isnt undefined then pointer.pointerId else pointer.identifier
    @pointerDown event, pointer
    return

  pointerDown: (event, pointer) ->
    @_bindPostStartEvents event
    @emitEvent 'pointerDown', [
      event
      pointer
    ]
    return

  # hash of events to be bound after start event
  postStartEvents:
    mousedown: [
      'mousemove'
      'mouseup'
    ]
    touchstart: [
      'touchmove'
      'touchend'
      'touchcancel'
    ]
    pointerdown: [
      'pointermove'
      'pointerup'
      'pointercancel'
    ]
    MSPointerDown: [
      'MSPointerMove'
      'MSPointerUp'
      'MSPointerCancel'
    ]

  _bindPostStartEvents: (event) ->
    if not event
      return
    # get proper events to match start event
    events = @postStartEvents[event.type]
    # bind events to node
    events.forEach ((eventName) ->
      window.addEventListener eventName, @
      return
    ), @
    # save these arguments
    @_boundPointerEvents = events
    return

  _unbindPostStartEvents: ->
    # check for _boundEvents, in case dragEnd triggered twice (old IE8 bug)
    if not @_boundPointerEvents
      return
    @_boundPointerEvents.forEach ((eventName) ->
      window.removeEventListener eventName, @
      return
    ), @
    delete @_boundPointerEvents
    return

  # ----- move event ----- //
  onmousemove: (event) ->
    @_pointerMove event, event
    return

  onpointermove: (event) ->
    if event.pointerId is @pointerIdentifier
      @_pointerMove event, event
    return

  ontouchmove: (event) ->
    touch = @getTouch(event.changedTouches)
    if touch
      @_pointerMove event, touch
    return

  ###*
  # pointer move
  # @param {Event} event
  # @param {Event or Touch} pointer
  # @private
  ###
  _pointerMove: (event, pointer) ->
    @pointerMove event, pointer
    return

  # public
  pointerMove: (event, pointer) ->
    @emitEvent 'pointerMove', [
      event
      pointer
    ]
    return

  # ----- end event ----- //

  onmouseup: (event) ->
    @_pointerUp event, event
    return

  onpointerup: (event) ->
    if event.pointerId is @pointerIdentifier
      @_pointerUp event, event
    return

  ontouchend: (event) ->
    touch = @getTouch(event.changedTouches)
    if touch
      @_pointerUp event, touch
    return

  ###*
  # pointer up
  # @param {Event} event
  # @param {Event or Touch} pointer
  # @private
  ###
  _pointerUp: (event, pointer) ->
    @_pointerDone()
    @pointerUp event, pointer
    return

  # public
  pointerUp: (event, pointer) ->
    @emitEvent 'pointerUp', [
      event
      pointer
    ]
    return

  # ----- pointer done ----- //
  # triggered on pointer up & pointer cancel
  _pointerDone: ->
    # reset properties
    @isPointerDown = false
    delete @pointerIdentifier
    # remove events
    @_unbindPostStartEvents()
    @pointerDone()
    return

  pointerDone: ->
    @noop

  # ----- pointer cancel ----- //
  onpointercancel: (event) ->
    if event.pointerId is @pointerIdentifier
      @_pointerCancel event, event
    return

  ontouchcancel: (event) ->
    touch = @getTouch(event.changedTouches)
    if touch
      @_pointerCancel event, touch
    return

  ###*
  # pointer cancel
  # @param {Event} event
  # @param {Event or Touch} pointer
  # @private
  ###
  _pointerCancel: (event, pointer) ->
    @_pointerDone()
    @pointerCancel event, pointer
    return

  # public
  pointerCancel: (event, pointer) ->
    @emitEvent 'pointerCancel', [
      event
      pointer
    ]
    return

  # -----  ----- //
  # utility function for getting x/y coords from event
  Unipointer.getPointerPoint = (pointer) ->
    {
      x: pointer.pageX
      y: pointer.pageY
    }
