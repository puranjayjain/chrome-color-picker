module.exports =
class FloatingPanel

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
    @component = null

    # create a custom element for the floating panel
    FloatingPanelComponent = document.registerElement name
    @component = new FloatingPanelComponent
    @component.classList.add 'invisible'
    addTo.appendChild @component

  # add element to the panel
  add: (element) ->
    @component.appendChild element.component

  # toggle the visibility state of the dialog
  toggle: ->
    @component.classList.toggle 'invisible'

  # make the dialog invisible and discard the newly edited value
  close: ->
    @component.classList.add 'invisible'

  #destroy the element from the dom
  destroy: ->
    @component.parentNode.removeChild @component
