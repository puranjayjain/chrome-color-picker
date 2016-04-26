helper = require '../helper/helper'

module.exports =
class Sliders extends helper

  ###*
   * [constructor Sliders in atom]
   *
   * @method constructor
   *
   * @param  {[class]}   type  [a class for styling the slider]
   *
   * @return {[type]}    [description]
  ###
  constructor: (type) ->
    # declare inner slider component here
    @slider = document.createElement 'INPUT'
    @slider.setAttribute 'type', 'range'
    @setFocusable @slider

    # create a custom element for the inner panel if not already done
    @component = @createComponent 'ccp-slider'
    @component.classList.add type
    @component.appendChild @slider

  # getters and setters of the slider
  setValue: (value) ->
    @slider.value = value

  getValue: ->
    @slider.value

  setMax: (max) ->
    @slider.max = max

  # set a new color to the alpha slider
  setColor: (color) ->
    @component.setAttribute('style', "background-image: linear-gradient(to right, rgba(204, 154, 129, 0), #{color})")
