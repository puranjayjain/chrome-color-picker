helper = require '../helper/helper.coffee'

module.exports =
class Swatch extends helper

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
