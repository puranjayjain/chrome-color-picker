helper = require '../helper/helper.coffee'

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

    # create a custom element for the inner panel if not already done
    @component = @createComponent 'ccp-slider'
    @component.classList.add type
    @component.appendChild @slider
