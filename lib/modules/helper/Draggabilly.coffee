Unidragger = require './Draggabilly/UniDragger'
GetSizeClass = require './Draggabilly/GetSize'

###!
# Draggabilly v2.1.0
# Make that shiz draggable
# http://draggabilly.desandro.com
# MIT license
###

module.exports =
# inherit Unidragger methods and properties
class Draggabilly extends Unidragger
  # vars
  defaults: {}
  document: window.document
  # -------------------------- requestAnimationFrame -------------------------- //
  # get rAF, prefixed, if present
  requestAnimationFrame = window.requestAnimationFrame or window.webkitRequestAnimationFrame
  # fallback to setTimeout
  lastTime: 0
  # -------------------------- support -------------------------- //
  docElem: null
  transformProperty: null
  options: null

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
  constructor: (element, options) ->
    # init stuff
    @docElem = @document.documentElement
    @transformProperty = if typeof @docElem.style.transform is 'string' then 'transform' else 'WebkitTransform'
    # querySelector if string
    @element = if typeof element is 'string' then @document.querySelector(element) else element
    # options
    @options = extend({}, @defaults)
    @option options
    @_create()
    return

  applyGrid = (value, grid, method) ->
    method = method or 'round'
    if grid then Math[method](value / grid) * grid else value

  if not requestAnimationFrame
    requestAnimationFrame = (callback) ->
      currTime = (new Date).getTime()
      timeToCall = Math.max(0, 16 - (currTime - @lastTime))
      id = setTimeout(callback, timeToCall)
      @lastTime = currTime + timeToCall
      id


  ###*
  # set options
  # @param {Object} opts
  ###
  option: (opts) ->
    extend @options, opts
    return

  GetSize = (elem) ->
    gS = new GetSizeClass()
    gS.getSize(elem)

  _create: ->
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
    if style.position isnt 'relative' and style.position isnt 'absolute'
      @element.style.position = 'relative'
    @enable()
    @setHandles()
    return

  ###*
  # set this.handles and bind start events to 'em
  ###

  setHandles: ->
    @handles = if @options.handle then @element.querySelectorAll(@options.handle) else [ @element ]
    @bindHandles()
    return

  ###*
  # emits events via EvEmitter events
  # @param {String} type - name of event
  # @param {Event} event - original event
  # @param {Array} args - extra arguments
  ###

  dispatchEvent: (type, event, args) ->
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
    if styleSide.indexOf('%') isnt -1
      # convert percent into pixel for Safari, #75
      parentSize = GetSize(@element.parentNode)
      return parseFloat(styleSide) / 100 * parentSize[measure]
    parseInt styleSide, 10

  # add transform: translate( x, y ) to position

  _addTransformPosition: (style) ->
    transform = style[@transformProperty]
    # bail out if value is 'none'
    if transform.indexOf('matrix') isnt 0
      return
    # split matrix(1, 0, 0, 1, x, y)
    matrixValues = transform.split(',')
    # translate X value is in 12th or 4th position
    xIndex = if transform.indexOf('matrix3d') is 0 then 12 else 4
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

  pointerDown: (event, pointer) ->
    @_dragPointerDown event, pointer
    # kludge to blur focused inputs in dragger
    focused = document.activeElement
    # do not blur body for IE10, metafizzy/flickity#117
    if focused and focused.blur and focused isnt document.body
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

  pointerMove: (event, pointer) ->
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

  dragStart: (event, pointer) ->
    if not @isEnabled
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

  measureContainment: ->
    containment = @options.containment
    if not containment
      return
    # use element if element
    container = if isElement(containment) then containment else if typeof containment is 'string' then document.querySelector(containment) else @element.parentNode
    elemSize = GetSize(@element)
    containerSize = GetSize(container)
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

  dragMove: (event, pointer, moveVector) ->
    if not @isEnabled
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
    dragX = if @options.axis is 'y' then 0 else dragX
    dragY = if @options.axis is 'x' then 0 else dragY
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

  containDrag: (axis, drag, grid) ->
    if not @options.containment
      return drag
    measure = if axis is 'x' then 'width' else 'height'
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

  pointerUp: (event, pointer) ->
    @element.classList.remove 'is-pointer-down'
    @dispatchEvent 'pointerUp', event, [ pointer ]
    @_dragPointerUp event, pointer
    return

  ###*
  # drag end
  # @param {Event} event
  # @param {Event or Touch} pointer
  ###

  dragEnd: (event, pointer) ->
    if not @isEnabled
      return
    # use top left position when complete
    if @transformProperty
      @element.style[@transformProperty] = ''
      @setLeftTop()
    @element.classList.remove 'is-dragging'
    @dispatchEvent 'dragEnd', event, [ pointer ]
    return

  # -------------------------- animation -------------------------- //

  animate: ->
    # only render and animate if dragging
    if not @isDragging
      return
    @positionDrag()
    _this = @
    requestAnimationFrame ->
      _this.animate()
      return
    return

  # left/top positioning

  setLeftTop: ->
    @element.style.left = "#{@position.x}px"
    @element.style.top = "#{@position.y}px"
    return

  positionDrag: ->
    @element.style[@transformProperty] = "translate3d(#{@dragPoint.x}px, #{@dragPoint.y}px, 0)"
    return

  # ----- staticClick ----- //

  staticClick: (event, pointer) ->
    @dispatchEvent 'staticClick', event, [ pointer ]
    return

  # ----- methods ----- //

  enable: ->
    @isEnabled = true
    return

  disable: ->
    @isEnabled = false
    if @isDragging
      @dragEnd()
    return

  destroy: ->
    @disable()
    # reset styles
    @element.style[@transformProperty] = ''
    @element.style.left = ''
    @element.style.top = ''
    @element.style.position = ''
    # unbind handles
    @unbindHandles()
    return
