helper = require '../helper/helper.coffee'

module.exports =
class Palette extends helper

  ###*
   * [constructor Palette in atom]
   *
   * @method constructor
   *
   * @return {[type]}    [description]
  ###
  constructor: ->
    # create a custom element for the inner panel if not already done
    @component = @createComponent 'ccp-palette-inner'

  # create the material design Palette
  initMaterial: ->
    # do something here

  # create the empty custom Palette
  initCustom: ->
    # body...

  # create the page's Palette
  # TODO make this feature
  # create the project's Palette
  # TODO make this feature

  # create the page popup palette
  initPopupPalette: ->
    # body...
