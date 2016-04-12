###!
# Draggabilly PACKAGED v2.1.0
# Make that shiz draggable
# http://draggabilly.desandro.com
# Converted to coffescript
# MIT license
###

### jshint browser: true, strict: true, undef: true, unused: true ###

((window, factory) ->
  # module end point
  module.exports = factory(window)
  return
) window, (window) ->
  # ----- utils ----- //
  arraySlice = Array::slice

###!
# getSize v2.0.2
# measure size of elements
# MIT license
###

###jshint browser: true, strict: true, undef: true, unused: true ###

###global define: false, module: false, console: false ###

((window, factory) ->
  # CommonJS
  module.exports = factory()
  return
) window, ->
  logError = if typeof console == 'undefined' then noop else ((message) ->
    console.error message
    return
  )
  # -------------------------- measurements -------------------------- //
  measurements = [
    'paddingLeft'
    'paddingRight'
    'paddingTop'
    'paddingBottom'
    'marginLeft'
    'marginRight'
    'marginTop'
    'marginBottom'
    'borderLeftWidth'
    'borderRightWidth'
    'borderTopWidth'
    'borderBottomWidth'
  ]
  measurementsLength = measurements.length
  # -------------------------- setup -------------------------- //
  isSetup = false
  isBoxSizeOuter = undefined
  # -------------------------- helpers -------------------------- //
  # get a number from a string, not a percentage

  getStyleSize = (value) ->
    num = parseFloat(value)
    # not a percent like '100%', and a number
    isValid = value.indexOf('%') == -1 and !isNaN(num)
    isValid and num

  noop = ->

  getZeroSize = ->
    size =
      width: 0
      height: 0
      innerWidth: 0
      innerHeight: 0
      outerWidth: 0
      outerHeight: 0
    i = 0
    while i < measurementsLength
      measurement = measurements[i]
      size[measurement] = 0
      i++
    size

  # -------------------------- getStyle -------------------------- //

  ###*
  # getStyle, get style of element, check for Firefox bug
  # https://bugzilla.mozilla.org/show_bug.cgi?id=548397
  ###

  getStyle = (elem) ->
    style = getComputedStyle(elem)
    if !style
      logError 'Style returned ' + style + '. Are you running this code in a hidden iframe on Firefox? ' + 'See http://bit.ly/getsizebug1'
    style

  ###*
  # setup
  # check isBoxSizerOuter
  # do on first getSize() rather than on page load for Firefox bug
  ###

  setup = ->
    # setup once
    if isSetup
      return
    isSetup = true
    # -------------------------- box sizing -------------------------- //

    ###*
    # WebKit measures the outer-width on style.width on border-box elems
    # IE & Firefox<29 measures the inner-width
    ###

    div = document.createElement('div')
    div.style.width = '200px'
    div.style.padding = '1px 2px 3px 4px'
    div.style.borderStyle = 'solid'
    div.style.borderWidth = '1px 2px 3px 4px'
    div.style.boxSizing = 'border-box'
    body = document.body or document.documentElement
    body.appendChild div
    style = getStyle(div)
    getSize.isBoxSizeOuter = isBoxSizeOuter = getStyleSize(style.width) == 200
    body.removeChild div
    return

  # -------------------------- getSize -------------------------- //

  getSize = (elem) ->
    setup()
    # use querySeletor if elem is string
    if typeof elem == 'string'
      elem = document.querySelector(elem)
    # do not proceed on non-objects
    if !elem or typeof elem != 'object' or !elem.nodeType
      return
    style = getStyle(elem)
    # if hidden, everything is 0
    if style.display == 'none'
      return getZeroSize()
    size = {}
    size.width = elem.offsetWidth
    size.height = elem.offsetHeight
    isBorderBox = size.isBorderBox = style.boxSizing == 'border-box'
    # get all measurements
    i = 0
    while i < measurementsLength
      measurement = measurements[i]
      value = style[measurement]
      num = parseFloat(value)
      # any 'auto', 'medium' value will be 0
      size[measurement] = if !isNaN(num) then num else 0
      i++
    paddingWidth = size.paddingLeft + size.paddingRight
    paddingHeight = size.paddingTop + size.paddingBottom
    marginWidth = size.marginLeft + size.marginRight
    marginHeight = size.marginTop + size.marginBottom
    borderWidth = size.borderLeftWidth + size.borderRightWidth
    borderHeight = size.borderTopWidth + size.borderBottomWidth
    isBorderBoxSizeOuter = isBorderBox and isBoxSizeOuter
    # overwrite width and height if we can get it from style
    styleWidth = getStyleSize(style.width)
    if styleWidth != false
      size.width = styleWidth + (if isBorderBoxSizeOuter then 0 else paddingWidth + borderWidth)
    styleHeight = getStyleSize(style.height)
    if styleHeight != false
      size.height = styleHeight + (if isBorderBoxSizeOuter then 0 else paddingHeight + borderHeight)
    size.innerWidth = size.width - (paddingWidth + borderWidth)
    size.innerHeight = size.height - (paddingHeight + borderHeight)
    size.outerWidth = size.width + marginWidth
    size.outerHeight = size.height + marginHeight
    size

  getSize

###*
# EvEmitter v1.0.1
# Lil' event emitter
# MIT License
###

### jshint unused: true, undef: true, strict: true ###

((global, factory) ->
  # universal module definition
  # CommonJS - Browserify, Webpack
  module.exports = factory()
  return
) this, ->
  proto = EvEmitter.prototype

  EvEmitter = ->

  proto.on = (eventName, listener) ->
    if !eventName or !listener
      return
    # set events hash
    events = @_events = @_events or {}
    # set listeners array
    listeners = events[eventName] = events[eventName] or []
    # only add once
    if listeners.indexOf(listener) == -1
      listeners.push listener
    this

  proto.once = (eventName, listener) ->
    if !eventName or !listener
      return
    # add event
    @on eventName, listener
    # set once flag
    # set onceEvents hash
    onceEvents = @_onceEvents = @_onceEvents or {}
    # set onceListeners array
    onceListeners = onceEvents[eventName] = onceEvents[eventName] or []
    # set flag
    onceListeners[listener] = true
    this

  proto.off = (eventName, listener) ->
    listeners = @_events and @_events[eventName]
    if !listeners or !listeners.length
      return
    index = listeners.indexOf(listener)
    if index != -1
      listeners.splice index, 1
    this

  proto.emitEvent = (eventName, args) ->
    listeners = @_events and @_events[eventName]
    if !listeners or !listeners.length
      return
    i = 0
    listener = listeners[i]
    args = args or []
    # once stuff
    onceListeners = @_onceEvents and @_onceEvents[eventName]
    while listener
      isOnce = onceListeners and onceListeners[listener]
      if isOnce
        # remove listener
        # remove before trigger to prevent recursion
        @off eventName, listener
        # unset once flag
        delete onceListeners[listener]
      # trigger listener
      listener.apply this, args
      # get next listener
      i += if isOnce then 0 else 1
      listener = listeners[i]
    this

  EvEmitter

###!
# Unipointer v2.1.0
# base class for doing one thing with pointer event
# MIT license
###

###jshint browser: true, undef: true, unused: true, strict: true ###

((window, factory) ->
  # universal module definition
  # CommonJS
  module.exports = factory(window, require('ev-emitter'))
  return
) window, (window, EvEmitter) ->
  # inherit EvEmitter
  proto = Unipointer.prototype = Object.create(EvEmitter.prototype)

  noop = ->

  Unipointer = ->

  proto.bindStartEvent = (elem) ->
    @_bindStartEvent elem, true
    return

  proto.unbindStartEvent = (elem) ->
    @_bindStartEvent elem, false
    return

  ###*
  # works as unbinder, as you can ._bindStart( false ) to unbind
  # @param {Boolean} isBind - will unbind if falsey
  ###

  proto._bindStartEvent = (elem, isBind) ->
    # munge isBind, default to true
    isBind = if isBind == undefined then true else ! !isBind
    bindMethod = if isBind then 'addEventListener' else 'removeEventListener'
    if window.navigator.pointerEnabled
      # W3C Pointer Events, IE11. See https://coderwall.com/p/mfreca
      elem[bindMethod] 'pointerdown', this
    else if window.navigator.msPointerEnabled
      # IE10 Pointer Events
      elem[bindMethod] 'MSPointerDown', this
    else
      # listen for both, for devices like Chrome Pixel
      elem[bindMethod] 'mousedown', this
      elem[bindMethod] 'touchstart', this
    return

  # trigger handler methods for events

  proto.handleEvent = (event) ->
    method = 'on' + event.type
    if @[method]
      @[method] event
    return

  # returns the touch that we're keeping track of

  proto.getTouch = (touches) ->
    i = 0
    while i < touches.length
      touch = touches[i]
      if touch.identifier == @pointerIdentifier
        return touch
      i++
    return

  # ----- start event ----- //

  proto.onmousedown = (event) ->
    # dismiss clicks from right or middle buttons
    button = event.button
    if button and button != 0 and button != 1
      return
    @_pointerDown event, event
    return

  proto.ontouchstart = (event) ->
    @_pointerDown event, event.changedTouches[0]
    return

  proto.onMSPointerDown =
  proto.onpointerdown = (event) ->
    @_pointerDown event, event
    return

  ###*
  # pointer start
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto._pointerDown = (event, pointer) ->
    # dismiss other pointers
    if @isPointerDown
      return
    @isPointerDown = true
    # save pointer identifier to match up touch events
    @pointerIdentifier = if pointer.pointerId != undefined then pointer.pointerId else pointer.identifier
    @pointerDown event, pointer
    return

  proto.pointerDown = (event, pointer) ->
    @_bindPostStartEvents event
    @emitEvent 'pointerDown', [
      event
      pointer
    ]
    return

  # hash of events to be bound after start event
  postStartEvents =
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

  proto._bindPostStartEvents = (event) ->
    if !event
      return
    # get proper events to match start event
    events = postStartEvents[event.type]
    # bind events to node
    events.forEach ((eventName) ->
      window.addEventListener eventName, this
      return
    ), this
    # save these arguments
    @_boundPointerEvents = events
    return

  proto._unbindPostStartEvents = ->
    # check for _boundEvents, in case dragEnd triggered twice (old IE8 bug)
    if !@_boundPointerEvents
      return
    @_boundPointerEvents.forEach ((eventName) ->
      window.removeEventListener eventName, this
      return
    ), this
    delete @_boundPointerEvents
    return

  # ----- move event ----- //

  proto.onmousemove = (event) ->
    @_pointerMove event, event
    return

  proto.onMSPointerMove =
  proto.onpointermove = (event) ->
    if event.pointerId == @pointerIdentifier
      @_pointerMove event, event
    return

  proto.ontouchmove = (event) ->
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

  proto._pointerMove = (event, pointer) ->
    @pointerMove event, pointer
    return

  # public

  proto.pointerMove = (event, pointer) ->
    @emitEvent 'pointerMove', [
      event
      pointer
    ]
    return

  # ----- end event ----- //

  proto.onmouseup = (event) ->
    @_pointerUp event, event
    return

  proto.onMSPointerUp =
  proto.onpointerup = (event) ->
    if event.pointerId == @pointerIdentifier
      @_pointerUp event, event
    return

  proto.ontouchend = (event) ->
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

  proto._pointerUp = (event, pointer) ->
    @_pointerDone()
    @pointerUp event, pointer
    return

  # public

  proto.pointerUp = (event, pointer) ->
    @emitEvent 'pointerUp', [
      event
      pointer
    ]
    return

  # ----- pointer done ----- //
  # triggered on pointer up & pointer cancel

  proto._pointerDone = ->
    # reset properties
    @isPointerDown = false
    delete @pointerIdentifier
    # remove events
    @_unbindPostStartEvents()
    @pointerDone()
    return

  proto.pointerDone = noop
  # ----- pointer cancel ----- //
  proto.onMSPointerCancel =
  proto.onpointercancel = (event) ->
    if event.pointerId == @pointerIdentifier
      @_pointerCancel event, event
    return

  proto.ontouchcancel = (event) ->
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

  proto._pointerCancel = (event, pointer) ->
    @_pointerDone()
    @pointerCancel event, pointer
    return

  # public

  proto.pointerCancel = (event, pointer) ->
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

  # -----  ----- //
  Unipointer

###!
# Unidragger v2.1.0
# Draggable base class
# MIT license
###

###jshint browser: true, unused: true, undef: true, strict: true ###

((window, factory) ->
  # universal module definition
  # CommonJS
  module.exports = factory(window, require('unipointer'))
  return
) window, (window, Unipointer) ->
  # inherit Unipointer & EvEmitter
  proto = Unidragger.prototype = Object.create(Unipointer.prototype)
  # ----- bind start ----- //
  # -----  ----- //

  noop = ->

  # -------------------------- Unidragger -------------------------- //

  Unidragger = ->

  proto.bindHandles = ->
    @_bindHandles true
    return

  proto.unbindHandles = ->
    @_bindHandles false
    return

  navigator = window.navigator

  ###*
  # works as unbinder, as you can .bindHandles( false ) to unbind
  # @param {Boolean} isBind - will unbind if falsey
  ###

  proto._bindHandles = (isBind) ->
    # munge isBind, default to true
    isBind = if isBind == undefined then true else ! !isBind
    # extra bind logic
    binderExtra = undefined
    if navigator.pointerEnabled

      binderExtra = (handle) ->
        # disable scrolling on the element
        handle.style.touchAction = if isBind then 'none' else ''
        return

    else if navigator.msPointerEnabled

      binderExtra = (handle) ->
        # disable scrolling on the element
        handle.style.msTouchAction = if isBind then 'none' else ''
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
      handle[bindMethod] 'click', this
      i++
    return

  # ----- start event ----- //

  ###*
  # pointer start
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto.pointerDown = (event, pointer) ->
    # dismiss range sliders
    if event.target.nodeName == 'INPUT' and event.target.type == 'range'
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

  proto._dragPointerDown = (event, pointer) ->
    # track to see when dragging starts
    @pointerDownPoint = Unipointer.getPointerPoint(pointer)
    canPreventDefault = @canPreventDefaultOnPointerDown(event, pointer)
    if canPreventDefault
      event.preventDefault()
    return

  # overwriteable method so Flickity can prevent for scrolling

  proto.canPreventDefaultOnPointerDown = (event) ->
    # prevent default, unless touchstart or <select>
    event.target.nodeName != 'SELECT'

  # ----- move event ----- //

  ###*
  # drag move
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto.pointerMove = (event, pointer) ->
    moveVector = @_dragPointerMove(event, pointer)
    @emitEvent 'pointerMove', [
      event
      pointer
      moveVector
    ]
    @_dragMove event, pointer, moveVector
    return

  # base pointer move logic

  proto._dragPointerMove = (event, pointer) ->
    movePoint = Unipointer.getPointerPoint(pointer)
    moveVector =
      x: movePoint.x - (@pointerDownPoint.x)
      y: movePoint.y - (@pointerDownPoint.y)
    # start drag if pointer has moved far enough to start drag
    if !@isDragging and @hasDragStarted(moveVector)
      @_dragStart event, pointer
    moveVector

  # condition if pointer has moved far enough to start drag

  proto.hasDragStarted = (moveVector) ->
    Math.abs(moveVector.x) > 3 or Math.abs(moveVector.y) > 3

  # ----- end event ----- //

  ###*
  # pointer up
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto.pointerUp = (event, pointer) ->
    @emitEvent 'pointerUp', [
      event
      pointer
    ]
    @_dragPointerUp event, pointer
    return

  proto._dragPointerUp = (event, pointer) ->
    if @isDragging
      @_dragEnd event, pointer
    else
      # pointer didn't move enough for drag to start
      @_staticClick event, pointer
    return

  # -------------------------- drag -------------------------- //
  # dragStart

  proto._dragStart = (event, pointer) ->
    @isDragging = true
    @dragStartPoint = Unipointer.getPointerPoint(pointer)
    # prevent clicks
    @isPreventingClicks = true
    @dragStart event, pointer
    return

  proto.dragStart = (event, pointer) ->
    @emitEvent 'dragStart', [
      event
      pointer
    ]
    return

  # dragMove

  proto._dragMove = (event, pointer, moveVector) ->
    # do not drag if not dragging yet
    if !@isDragging
      return
    @dragMove event, pointer, moveVector
    return

  proto.dragMove = (event, pointer, moveVector) ->
    event.preventDefault()
    @emitEvent 'dragMove', [
      event
      pointer
      moveVector
    ]
    return

  # dragEnd

  proto._dragEnd = (event, pointer) ->
    # set flags
    @isDragging = false
    # re-enable clicking async
    setTimeout (->
      delete @isPreventingClicks
      return
    ).bind(this)
    @dragEnd event, pointer
    return

  proto.dragEnd = (event, pointer) ->
    @emitEvent 'dragEnd', [
      event
      pointer
    ]
    return

  # ----- onclick ----- //
  # handle all clicks and prevent clicks when dragging

  proto.onclick = (event) ->
    if @isPreventingClicks
      event.preventDefault()
    return

  # ----- staticClick ----- //
  # triggered after pointer down & up with no/tiny movement

  proto._staticClick = (event, pointer) ->
    # ignore emulated mouse up clicks
    if @isIgnoringMouseUp and event.type == 'mouseup'
      return
    # allow click in <input>s and <textarea>s
    nodeName = event.target.nodeName
    if nodeName == 'INPUT' or nodeName == 'TEXTAREA'
      event.target.focus()
    @staticClick event, pointer
    # set flag for emulated clicks 300ms after touchend
    if event.type != 'mouseup'
      @isIgnoringMouseUp = true
      # reset flag after 300ms
      setTimeout (->
        delete @isIgnoringMouseUp
        return
      ).bind(this), 400
    return

  proto.staticClick = (event, pointer) ->
    @emitEvent 'staticClick', [
      event
      pointer
    ]
    return

  # ----- utils ----- //
  Unidragger.getPointerPoint = Unipointer.getPointerPoint
  # -----  ----- //
  Unidragger

###!
# Draggabilly v2.1.0
# Make that shiz draggable
# http://draggabilly.desandro.com
# MIT license
###

###jshint browser: true, strict: true, undef: true, unused: true ###

((window, factory) ->
  # universal module definition
  # CommonJS
  module.exports = factory(window, require('get-size'), require('unidragger'))
  return
) window, (window, getSize, Unidragger) ->
  # vars
  document = window.document
  # -------------------------- requestAnimationFrame -------------------------- //
  # get rAF, prefixed, if present
  requestAnimationFrame = window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame
  # fallback to setTimeout
  lastTime = 0

  noop = ->

  # -------------------------- helpers -------------------------- //
  # extend objects

  extend = (a, b) ->
    for prop of b
      a[prop] = b[prop]
    a

  isElement = (obj) ->
    obj instanceof HTMLElement

  # --------------------------  -------------------------- //

  Draggabilly = (element, options) ->
    # querySelector if string
    @element = if typeof element == 'string' then document.querySelector(element) else element
    # options
    @options = extend({}, @constructor.defaults)
    @option options
    @_create()
    return

  applyGrid = (value, grid, method) ->
    method = method or 'round'
    if grid then Math[method](value / grid) * grid else value

  if !requestAnimationFrame

    requestAnimationFrame = (callback) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = setTimeout(callback, timeToCall)
      lastTime = currTime + timeToCall
      id

  # -------------------------- support -------------------------- //
  docElem = document.documentElement
  transformProperty = if typeof docElem.style.transform == 'string' then 'transform' else 'WebkitTransform'
  # inherit Unidragger methods
  proto = Draggabilly.prototype = Object.create(Unidragger.prototype)
  Draggabilly.defaults = {}

  ###*
  # set options
  # @param {Object} opts
  ###

  proto.option = (opts) ->
    extend @options, opts
    return

  proto._create = ->
    # properties
    @position = {}
    @_getPosition()
    @startPoint =
      x: 0
      y: 0
    @dragPoint =
      x: 0
      y: 0
    @startPosition = extend({}, @position)
    # set relative positioning
    style = getComputedStyle(@element)
    if style.position != 'relative' and style.position != 'absolute'
      @element.style.position = 'relative'
    @enable()
    @setHandles()
    return

  ###*
  # set this.handles and bind start events to 'em
  ###

  proto.setHandles = ->
    @handles = if @options.handle then @element.querySelectorAll(@options.handle) else [ @element ]
    @bindHandles()
    return

  ###*
  # emits events via EvEmitter events
  # @param {String} type - name of event
  # @param {Event} event - original event
  # @param {Array} args - extra arguments
  ###

  proto.dispatchEvent = (type, event, args) ->
    emitArgs = [ event ].concat(args)
    @emitEvent type, emitArgs
    return

  # -------------------------- position -------------------------- //
  # get x/y position from style

  Draggabilly::_getPosition = ->
    style = getComputedStyle(@element)
    x = @_getPositionCoord(style.left, 'width')
    y = @_getPositionCoord(style.top, 'height')
    # clean up 'auto' or other non-integer values
    @position.x = if isNaN(x) then 0 else x
    @position.y = if isNaN(y) then 0 else y
    @_addTransformPosition style
    return

  Draggabilly::_getPositionCoord = (styleSide, measure) ->
    if styleSide.indexOf('%') != -1
      # convert percent into pixel for Safari, #75
      parentSize = getSize(@element.parentNode)
      return parseFloat(styleSide) / 100 * parentSize[measure]
    parseInt styleSide, 10

  # add transform: translate( x, y ) to position

  proto._addTransformPosition = (style) ->
    transform = style[transformProperty]
    # bail out if value is 'none'
    if transform.indexOf('matrix') != 0
      return
    # split matrix(1, 0, 0, 1, x, y)
    matrixValues = transform.split(',')
    # translate X value is in 12th or 4th position
    xIndex = if transform.indexOf('matrix3d') == 0 then 12 else 4
    translateX = parseInt(matrixValues[xIndex], 10)
    # translate Y value is in 13th or 5th position
    translateY = parseInt(matrixValues[xIndex + 1], 10)
    @position.x += translateX
    @position.y += translateY
    return

  # -------------------------- events -------------------------- //

  ###*
  # pointer start
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto.pointerDown = (event, pointer) ->
    @_dragPointerDown event, pointer
    # kludge to blur focused inputs in dragger
    focused = document.activeElement
    # do not blur body for IE10, metafizzy/flickity#117
    if focused and focused.blur and focused != document.body
      focused.blur()
    # bind move and end events
    @_bindPostStartEvents event
    @element.classList.add 'is-pointer-down'
    @dispatchEvent 'pointerDown', event, [ pointer ]
    return

  ###*
  # drag move
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto.pointerMove = (event, pointer) ->
    moveVector = @_dragPointerMove(event, pointer)
    @dispatchEvent 'pointerMove', event, [
      pointer
      moveVector
    ]
    @_dragMove event, pointer, moveVector
    return

  ###*
  # drag start
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto.dragStart = (event, pointer) ->
    if !@isEnabled
      return
    @_getPosition()
    @measureContainment()
    # position _when_ drag began
    @startPosition.x = @position.x
    @startPosition.y = @position.y
    # reset left/top style
    @setLeftTop()
    @dragPoint.x = 0
    @dragPoint.y = 0
    @element.classList.add 'is-dragging'
    @dispatchEvent 'dragStart', event, [ pointer ]
    # start animation
    @animate()
    return

  proto.measureContainment = ->
    containment = @options.containment
    if !containment
      return
    # use element if element
    container = if isElement(containment) then containment else if typeof containment == 'string' then document.querySelector(containment) else @element.parentNode
    elemSize = getSize(@element)
    containerSize = getSize(container)
    elemRect = @element.getBoundingClientRect()
    containerRect = container.getBoundingClientRect()
    borderSizeX = containerSize.borderLeftWidth + containerSize.borderRightWidth
    borderSizeY = containerSize.borderTopWidth + containerSize.borderBottomWidth
    position = @relativeStartPosition =
      x: elemRect.left - (containerRect.left + containerSize.borderLeftWidth)
      y: elemRect.top - (containerRect.top + containerSize.borderTopWidth)
    @containSize =
      width: containerSize.width - borderSizeX - (position.x) - (elemSize.width)
      height: containerSize.height - borderSizeY - (position.y) - (elemSize.height)
    return

  # ----- move event ----- //

  ###*
  # drag move
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto.dragMove = (event, pointer, moveVector) ->
    if !@isEnabled
      return
    dragX = moveVector.x
    dragY = moveVector.y
    grid = @options.grid
    gridX = grid and grid[0]
    gridY = grid and grid[1]
    dragX = applyGrid(dragX, gridX)
    dragY = applyGrid(dragY, gridY)
    dragX = @containDrag('x', dragX, gridX)
    dragY = @containDrag('y', dragY, gridY)
    # constrain to axis
    dragX = if @options.axis == 'y' then 0 else dragX
    dragY = if @options.axis == 'x' then 0 else dragY
    @position.x = @startPosition.x + dragX
    @position.y = @startPosition.y + dragY
    # set dragPoint properties
    @dragPoint.x = dragX
    @dragPoint.y = dragY
    @dispatchEvent 'dragMove', event, [
      pointer
      moveVector
    ]
    return

  proto.containDrag = (axis, drag, grid) ->
    if !@options.containment
      return drag
    measure = if axis == 'x' then 'width' else 'height'
    rel = @relativeStartPosition[axis]
    min = applyGrid(-rel, grid, 'ceil')
    max = @containSize[measure]
    max = applyGrid(max, grid, 'floor')
    Math.min max, Math.max(min, drag)

  # ----- end event ----- //

  ###*
  # pointer up
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto.pointerUp = (event, pointer) ->
    @element.classList.remove 'is-pointer-down'
    @dispatchEvent 'pointerUp', event, [ pointer ]
    @_dragPointerUp event, pointer
    return

  ###*
  # drag end
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  proto.dragEnd = (event, pointer) ->
    if !@isEnabled
      return
    # use top left position when complete
    if transformProperty
      @element.style[transformProperty] = ''
      @setLeftTop()
    @element.classList.remove 'is-dragging'
    @dispatchEvent 'dragEnd', event, [ pointer ]
    return

  # -------------------------- animation -------------------------- //

  proto.animate = ->
    # only render and animate if dragging
    if !@isDragging
      return
    @positionDrag()
    _this = this
    requestAnimationFrame ->
      _this.animate()
      return
    return

  # left/top positioning

  proto.setLeftTop = ->
    @element.style.left = @position.x + 'px'
    @element.style.top = @position.y + 'px'
    return

  proto.positionDrag = ->
    @element.style[transformProperty] = 'translate3d( ' + @dragPoint.x + 'px, ' + @dragPoint.y + 'px, 0)'
    return

  # ----- staticClick ----- //

  proto.staticClick = (event, pointer) ->
    @dispatchEvent 'staticClick', event, [ pointer ]
    return

  # ----- methods ----- //

  proto.enable = ->
    @isEnabled = true
    return

  proto.disable = ->
    @isEnabled = false
    if @isDragging
      @dragEnd()
    return

  proto.destroy = ->
    @disable()
    # reset styles
    @element.style[transformProperty] = ''
    @element.style.left = ''
    @element.style.top = ''
    @element.style.position = ''
    # unbind handles
    @unbindHandles()
    return

  Draggabilly
