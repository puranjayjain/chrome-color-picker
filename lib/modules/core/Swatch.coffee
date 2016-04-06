helper = require '../helper/helper.coffee'

module.exports =
class Swatch extends helper

  ###*
   * [constructor Swatch in atom]
   *
   * @method constructor
   *
   * @param  {[class]}   type  [a class for styling the swatch]
   *
   * @return {[type]}    [description]
  ###
  constructor: (type) ->
    @name = 'chrome-color-picker-swatch'
    @component = null

    # create a custom element for the inner panel if not already done
    if not @name.isRegistered() then document.registerElement @name
    @component = document.createElement @name
    @component.classList.add type

  # add element to the panel
  add: (element) ->
    @component.appendChild element.component
