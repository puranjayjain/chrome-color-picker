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
