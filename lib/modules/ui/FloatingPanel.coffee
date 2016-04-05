module.exports =
class FloatingPanel

  ###*
   * [constructor FloatingPanel in atom]
   *
   * @method constructor
   *
   * @param  {[tag]}         name  [name of the element like x-foo]
   * @param  {[selector]}    addTo [add to which dom element]
   *
   * @return {[type]}    [description]
  ###
  constructor: (name, addTo) ->
    @component = null

    # create a custom element for the floating panel
    FloatingPanelComponent = document.registerElement name
    @component = new FloatingPanelComponent
    @component.classList.add 'invisible'
    document.querySelector(addTo).appendChild @component

  # toggle the visibility state of the dialog
  toggle: ->
    console.log @component
    @component.classList.toggle 'invisible'
