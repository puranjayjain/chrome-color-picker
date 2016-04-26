tabbable = require('./FocusTrap/Tabbable')
trap = undefined
tabbableNodes = undefined
previouslyFocused = undefined
activeFocusTrap = undefined
config = undefined

activate = (element, options) ->
  # There can be only one focus trap at a time
  if activeFocusTrap
    deactivate returnFocus: false
  activeFocusTrap = true
  trap = if typeof element is 'string' then document.querySelector(element) else element
  config = options or {}
  previouslyFocused = document.activeElement
  updateTabbableNodes()
  tryFocus firstFocusNode()
  document.addEventListener 'focus', checkFocus, true
  document.addEventListener 'click', checkClick, true
  document.addEventListener 'mousedown', checkClickInit, true
  document.addEventListener 'touchstart', checkClickInit, true
  document.addEventListener 'keydown', checkKey, true
  return

firstFocusNode = ->
  node = undefined
  if not config.initialFocus
    node = tabbableNodes[0]
    if not node
      throw new Error('You can\'t have a focus-trap without at least one focusable element')
    return node
  if typeof config.initialFocus is 'string'
    node = document.querySelector(config.initialFocus)
  else
    node = config.initialFocus
  if not node
    throw new Error('The `initialFocus` selector you passed refers to no known node')
  node

deactivate = (deactivationOptions) ->
  deactivationOptions = deactivationOptions or {}
  if not activeFocusTrap
    return
  activeFocusTrap = false
  document.removeEventListener 'focus', checkFocus, true
  document.removeEventListener 'click', checkClick, true
  document.addEventListener 'mousedown', checkClickInit, true
  document.addEventListener 'touchstart', checkClickInit, true
  document.removeEventListener 'keydown', checkKey, true
  if config.onDeactivate
    config.onDeactivate()
  if deactivationOptions.returnFocus isnt false
    setTimeout (->
      tryFocus previouslyFocused
      return
    ), 0
  return

# This needs to be done on mousedown and touchstart instead of click
# so that it precedes the focus event

checkClickInit = (e) ->
  if config.clickOutsideDeactivates
    deactivate returnFocus: false
  return

checkClick = (e) ->
  if config.clickOutsideDeactivates
    return
  if trap.contains(e.target)
    return
  e.preventDefault()
  e.stopImmediatePropagation()
  return

checkFocus = (e) ->
  if trap.contains(e.target)
    return
  e.preventDefault()
  e.stopImmediatePropagation()
  e.target.blur()
  return

checkKey = (e) ->
  if e.key is 'Tab' or e.keyCode is 9
    handleTab e
  if config.escapeDeactivates isnt false and isEscapeEvent(e)
    deactivate()
  return

handleTab = (e) ->
  e.preventDefault()
  updateTabbableNodes()
  currentFocusIndex = tabbableNodes.indexOf(e.target)
  lastTabbableNode = tabbableNodes[tabbableNodes.length - 1]
  firstTabbableNode = tabbableNodes[0]
  if e.shiftKey
    if e.target is firstTabbableNode
      tryFocus lastTabbableNode
      return
    tryFocus tabbableNodes[currentFocusIndex - 1]
    return
  if e.target is lastTabbableNode
    tryFocus firstTabbableNode
    return
  tryFocus tabbableNodes[currentFocusIndex + 1]
  return

updateTabbableNodes = ->
  tabbableNodes = tabbable(trap)
  return

tryFocus = (node) ->
  if not node or not node.focus
    return
  node.focus()
  if node.tagName.toLowerCase() is 'input'
    node.select()
  return

isEscapeEvent = (e) ->
  e.key is 'Escape' or e.key is 'Esc' or e.code is 'Escape' or e.keyCode is 27

module.exports =
  activate: activate
  deactivate: deactivate
