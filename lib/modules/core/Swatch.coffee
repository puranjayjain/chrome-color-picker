helper = require '../helper/helper'

module.exports =
class Swatch extends helper
  color: 'rgba(0,0,0,0)'
  ###*
   * [constructor Swatch in atom]
   *
   * @method constructor
   *
   * @param  {[class]}   type    [a class for styling the swatch]
   *
   * @return {[type]}    [description]
  ###
  constructor: (type) ->
    # create a custom element for the inner panel if not already done
    @component = @createComponent 'ccp-swatch'
    @component.classList.add type
    @setFocusable @component, 2

  # set a new color to the swatch component and the info
  setColor: (color) ->
    @color = color
    @component.setAttribute('style', 'background: ' + @color)

  # get the color of the swatch
  getColor: ->
    @color
