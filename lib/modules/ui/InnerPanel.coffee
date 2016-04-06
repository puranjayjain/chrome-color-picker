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
    @component = null

    # create a custom element for the inner panel if not already done
    if not name.isRegistered() then document.registerElement name
    @component = document.createElement name
    if type then @component.classList.add type

  # add element to the panel
  add: (element) ->
    @component.appendChild element.component
