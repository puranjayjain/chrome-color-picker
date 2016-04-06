helper = require '../helper/helper.coffee'

module.exports =
class Sliders extends helper

  ###*
   * [constructor Sliders in atom]
   *
   * @method constructor
   *
   * @param  {[class]}   type  [a class for styling the swatch]
   *
   * @return {[type]}    [description]
  ###
  constructor: (type) ->
    @name = 'chrome-color-picker-slider'
    @component = null
    @slider = document.createElement("INPUT");
    @slider.setAttribute("type", "range");

    # create a custom element for the inner panel if not already done
    if not @name.isRegistered() then document.registerElement @name
    @component = document.createElement @name
    @component.classList.add type
    @component.appendChild @slider

  # add element to the panel
  add: (element) ->
    @component.appendChild element.component
