helper = require '../helper/helper.coffee'

module.exports =
class InnerPanel extends helper
  ###*
   * [constructor InnerPanels in atom]
   *
   * @method constructor
   *
   * @param  {[tag]}     name  [name of the element like x-foo]
   *
   * @return {[type]}    [description]
  ###
  constructor: (name, type = false) ->
    @component = @createComponent name
    if type then @component.classList.add type

    # set a default tab index to make it focusable
    @component.tabIndex = '2'

  # set a new color to the canvas component
  setColor: (color) ->
    @component.setAttribute('style', 'background-image: linear-gradient(to right, white, ' + color + ')')
