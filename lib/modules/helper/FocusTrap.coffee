tabbable = require('./FocusTrap/Tabbable')
listeningFocusTrap = null

focusTrap = (element, userOptions) ->
  tabbableNodes = []
  nodeFocusedBeforeActivation = null
  active = false
  container = if typeof element == 'string' then document.querySelector(element) else element
  config = userOptions or {}

  activate = (activateOptions) ->
    defaultedActivateOptions = onActivate: if activateOptions and activateOptions.onActivate != undefined then activateOptions.onActivate else config.onActivate
    active = true
    nodeFocusedBeforeActivation = document.activeElement
    if defaultedActivateOptions.onActivate
      defaultedActivateOptions.onActivate()
    addListeners()
    trap

  deactivate = (deactivateOptions) ->
    defaultedDeactivateOptions =
      returnFocus: if deactivateOptions and deactivateOptions.returnFocus != undefined then deactivateOptions.returnFocus else config.returnFocusOnDeactivate
      onDeactivate: if deactivateOptions and deactivateOptions.onDeactivate != undefined then deactivateOptions.onDeactivate else config.onDeactivate
    removeListeners()
    if defaultedDeactivateOptions.onDeactivate
      defaultedDeactivateOptions.onDeactivate()
    if defaultedDeactivateOptions.returnFocus
      setTimeout (->
        tryFocus nodeFocusedBeforeActivation
        return
      ), 0
    active = false
    this

  addListeners = ->
    if !active
      return
    # There can be only one listening focus trap at a time
    if listeningFocusTrap
      listeningFocusTrap.unlisten()
    listeningFocusTrap = trap
    updateTabbableNodes()
    tryFocus firstFocusNode()
    document.addEventListener 'focus', checkFocus, true
    document.addEventListener 'click', checkClick, true
    document.addEventListener 'mousedown', checkPointerDown, true
    document.addEventListener 'touchstart', checkPointerDown, true
    document.addEventListener 'keydown', checkKey, true
    trap

  removeListeners = ->
    if !active or !listeningFocusTrap
      return
    document.removeEventListener 'focus', checkFocus, true
    document.removeEventListener 'click', checkClick, true
    document.removeEventListener 'mousedown', checkPointerDown, true
    document.removeEventListener 'touchstart', checkPointerDown, true
    document.removeEventListener 'keydown', checkKey, true
    listeningFocusTrap = null
    trap

  firstFocusNode = ->
    node = undefined
    if !config.initialFocus
      node = tabbableNodes[0]
      if !node
        throw new Error('You can\'t have a focus-trap without at least one focusable element')
      return node
    node = if typeof config.initialFocus == 'string' then document.querySelector(config.initialFocus) else config.initialFocus
    if !node
      throw new Error('`initialFocus` refers to no known node')
    node

  # This needs to be done on mousedown and touchstart instead of click
  # so that it precedes the focus event

  checkPointerDown = (e) ->
    if config.clickOutsideDeactivates
      deactivate returnFocus: false
    return

  checkClick = (e) ->
    if config.clickOutsideDeactivates
      return
    if container.contains(e.target)
      return
    e.preventDefault()
    e.stopImmediatePropagation()
    return

  checkFocus = (e) ->
    if container.contains(e.target)
      return
    e.preventDefault()
    e.stopImmediatePropagation()
    e.target.blur()
    return

  checkKey = (e) ->
    if e.key == 'Tab' or e.keyCode == 9
      handleTab e
    if config.escapeDeactivates != false and isEscapeEvent(e)
      deactivate()
    return

  handleTab = (e) ->
    e.preventDefault()
    updateTabbableNodes()
    currentFocusIndex = tabbableNodes.indexOf(e.target)
    lastTabbableNode = tabbableNodes[tabbableNodes.length - 1]
    firstTabbableNode = tabbableNodes[0]
    if e.shiftKey
      if e.target == firstTabbableNode or tabbableNodes.indexOf(e.target) == -1
        return tryFocus(lastTabbableNode)
      return tryFocus(tabbableNodes[currentFocusIndex - 1])
    if e.target == lastTabbableNode
      return tryFocus(firstTabbableNode)
    tryFocus tabbableNodes[currentFocusIndex + 1]
    return

  updateTabbableNodes = ->
    tabbableNodes = tabbable(container)
    return

  config.returnFocusOnDeactivate = if userOptions and userOptions.returnFocusOnDeactivate != undefined then userOptions.returnFocusOnDeactivate else true
  config.escapeDeactivates = if userOptions and userOptions.escapeDeactivates != undefined then userOptions.escapeDeactivates else true
  trap =
    activate: activate
    deactivate: deactivate
    pause: removeListeners
    unpause: addListeners
  trap

isEscapeEvent = (e) ->
  e.key == 'Escape' or e.key == 'Esc' or e.keyCode == 27

tryFocus = (node) ->
  if !node or !node.focus
    return
  node.focus()
  if node.tagName.toLowerCase() == 'input'
    node.select()
  return

module.exports = focusTrap
