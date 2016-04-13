###*
# EvEmitter v1.0.1
# Lil' event emitter
# MIT License
###

module.exports =
class EvEmitter

  on: (eventName, listener) ->
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

  once: (eventName, listener) ->
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

  off: (eventName, listener) ->
    listeners = @_events and @_events[eventName]
    if !listeners or !listeners.length
      return
    index = listeners.indexOf(listener)
    if index != -1
      listeners.splice index, 1
    this

  emitEvent: (eventName, args) ->
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
