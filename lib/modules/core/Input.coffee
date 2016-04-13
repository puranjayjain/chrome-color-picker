helper = require '../helper/helper.coffee'
TinyColor = require '../helper/TinyColor.coffee'

module.exports =
class Input extends helper
  active: {}
  color: null
  hex: null
  rgb: null
  hsl: null
  formats: ['hex','rgb','hsl']

  ###*
   * [constructor Input in atom]
   *
   * @method constructor
   *
   * @param  {[element]}    container   [the container element to attach to]
   *
   * @param  {[String]}     preference  [preferred active component]
   *
   * @return {[component]}  [description]
  ###
  constructor: (container, preference) ->
    element = ['hex']
    # dynamically create all types of input combinations and append them
    # Hex
    @hex = @createInput 'hex', element
    container.appendChild @hex
    # Rgb/a
    element = ['r','g','b','a']
    @rgb = @createInput 'rgb', element
    container.appendChild @rgb
    # Hsl/a
    element = ['h','s','l','a']
    @hsl = @createInput 'hsl', element
    container.appendChild @hsl
    # add a button to go through the list
    @button = document.createElement 'BUTTON'
    @button.classList.add 'btn', 'btn-primary', 'btn-sm', 'icon', 'icon-code'
    container.appendChild @button
    # add event listeners
    @attachEventListeners()
    # Set the currently active input along with it's type
    @active.type = preference
    # TODO switch preference according to the element and remove the invisible class
    @active.component = @[preference]
    @active.component.classList.remove 'invisible'

  ###*
   * [createInput creates an input element with text label below]
   *
   * @method createInput
   *
   * @param  {[String]}   name   [class name of the container element]
   * @param  {[Object]}   inputs [Object with display text to add below] e.g = ['R','G','B']
   *
   * @return {[panel]}    [returns the element to add to the main panel]
  ###
  createInput: (name, inputs) ->
    component = @createComponent 'ccp-input'
    for text in inputs
      inner = @createComponent 'ccp-input-inner'
      input = document.createElement 'atom-text-editor'
      input.setAttribute 'type', 'text'
      input.classList.add text
      input.setAttribute('mini', true)
      # innerEditor = input.getModel() to get inner text editor instance
      # innerEditor.getText and setText api to change the text
      div = document.createElement 'DIV'
      div.textContent = text
      inner.appendChild input
      inner.appendChild div
      component.appendChild inner
      component.classList.add name, 'invisible'
    component

  # add event listenerss to buttons
  attachEventListeners: ->
    self = @

    @button.addEventListener 'click', ->
      # cycle between active component states
      self.next()
      self.UpdateUI()

  ###*
   * [UpdateUI update the active text element]
   *
   * @method UpdateUI
   *
  ###
  UpdateUI: () ->
    format = @active.type
    @color = new TinyColor @color
    alpha = false
    thisColor = null
    # if the input format is hex but we have an alpha in the input, default to mr. muggles err rgb
    if @color.getAlpha() < 1
      alpha = true
      if format is 'hex'
        format = 'rgb'
        @changeFormat 'rgb'

    # do something according with the format
    # hex
    if format is 'hex'
      input = @hex.querySelector 'atom-text-editor.hex'
      input.getModel().setText @color.toHexString()

    # rgb
    if format is 'rgb'
      thisColor = @color.toRgb()
      input = @rgb.querySelector 'atom-text-editor.r'
      input.getModel().setText thisColor.r.toString()
      input = @rgb.querySelector 'atom-text-editor.g'
      input.getModel().setText thisColor.g.toString()
      input = @rgb.querySelector 'atom-text-editor.b'
      input.getModel().setText thisColor.b.toString()

    # toHsl
    if format is 'hsl'
      thisColor = @color.toHsl()
      input = @hsl.querySelector 'atom-text-editor.h'
      input.getModel().setText thisColor.h.toString()
      input = @hsl.querySelector 'atom-text-editor.s'
      input.getModel().setText (thisColor.s * 100).toString()
      input = @hsl.querySelector 'atom-text-editor.l'
      input.getModel().setText (thisColor.l * 100).toString()

    # if the alpha channel is present
    if alpha
      input = @[format].querySelector 'atom-text-editor.a'
      input.getModel().setText thisColor.a
      input.setAttribute 'style', 'display: none'
    else
      input.removeAttribute 'style'

  # change the current format to the one given
  changeFormat: (format) ->
    # hide all inputs
    for name in @formats
      @[name].classList.add 'invisible'

    # set it active
    @active.type = format
    @active.component = @[format]
    # show the format
    @active.component.classList.remove 'invisible'

  # sets the next component of the active array
  next: () ->
    current = @formats.indexOf(@active.type)
    if current is (@formats.length - 1)
      current = 0
    else
      current++

    @changeFormat @formats[current]
