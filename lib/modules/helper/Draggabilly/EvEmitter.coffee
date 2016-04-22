###*
# EvEmitter v1.0.1
# Lil' event emitter
# MIT License
###

module.exports =
class EvEmitter

  on: (eventName, listener) ->
    if not eventName or not listener
      return
    # set events hash
    events = @_events = @_events or {}
    # set listeners array
    listeners = events[eventName] = events[eventName] or []
    # only add once
    if listeners.indexOf(listener) is -1
      listeners.push listener
    @

  once: (eventName, listener) ->
    if not eventName or not listener
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
    @

  off: (eventName, listener) ->
    listeners = @_events and @_events[eventName]
    if not listeners or not listeners.length
      return
    index = listeners.indexOf(listener)
    if index isnt -1
      listeners.splice index, 1
    @

  emitEvent: (eventName, args) ->
    listeners = @_events and @_events[eventName]
    if not listeners or not listeners.length
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
      listener.apply @, args
      # get next listener
      i += if isOnce then 0 else 1
      listener = listeners[i]
    @
