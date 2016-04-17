helper = require '../helper/helper'

module.exports =
class FloatingPanel extends helper
  ###*
   * [constructor FloatingPanel in atom]
   *
   * @method constructor
   *
   * @param  {[tag]}         name  [name of the element like x-foo]
   * @param  {[element]}    addTo [add to which dom element]
   *
   * @return {[type]}    [description]
  ###
  constructor: (name, addTo) ->
    # create a custom element for the floating panel
    @component = @createComponent name
    @component.classList.add 'invisible'
    addTo.appendChild @component

  # place the dialog according to your need
  setPosition: (x, y) ->
    @component.setAttribute 'style', "left: #{x}px;top: #{y}px"

  # add element to the panel
  add: (element) ->
    @component.appendChild element.component

  # toggle the visibility state of the dialog
  toggle: ->
    @component.classList.toggle 'invisible'

  #destroy the element from the dom
  destroy: ->
    @component.parentNode.removeChild @component
