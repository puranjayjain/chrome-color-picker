helper = require '../helper/helper'
TinyColor = require '../helper/TinyColor'

module.exports =
class Input extends helper
  active: {}
  color: null
  hex: null
  rgb: null
  hsl: null
  formats: ['hex', 'rgb', 'hsl']
  # if the value was set using setText api
  forced: true

  ###*
   * [constructor Input in atom]
   *
   * @method constructor
   *
   * @param  {[element]}    container   [the container element to attach to]
   *
   * @return {[component]}  [description]
  ###
  constructor: (container) ->
    element = ['hex']
    # dynamically create all types of input combinations and append them
    # Hex
    @hex = @createInput 'hex', element
    container.appendChild @hex
    # Rgb/a
    element = ['r', 'g', 'b', 'a']
    @rgb = @createInput 'rgb', element
    container.appendChild @rgb
    # Hsl/a
    element = ['h', 's', 'l', 'a']
    @hsl = @createInput 'hsl', element
    container.appendChild @hsl
    innerButtons = @createComponent 'ccp-side-buttons'
    # add a button to go through the list
    @button = document.createElement 'BUTTON'
    @button.classList.add 'btn', 'btn-primary', 'btn-sm', 'icon', 'icon-code'
    @setFocusable @button
    # add a toggle button to open / close the palette
    @toggle = document.createElement 'BUTTON'
    @toggle.classList.add 'btn', 'btn-info', 'btn-sm', 'icon'
    @setFocusable @toggle
    # add icon according to the setting of the palette on open
    @toggle.classList.add if atom.config.get 'chrome-color-picker.General.paletteOpen' then 'icon-fold' else 'icon-unfold'
    # finally append them to the element
    innerButtons.appendChild @button
    innerButtons.appendChild @toggle
    # append the inner to the main container
    container.appendChild innerButtons
    # add event listeners
    @attachEventListeners()

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
      # set tab index so that the editor is focusable
      @removeFocusable input
      # innerEditor = input.getModel() to get inner text editor instance
      # innerEditor.getText and setText api to change the text
      div = document.createElement 'DIV'
      # exception for hex color
      if name is 'hex'
        text += ' or Named'
      div.textContent = text
      inner.appendChild input
      inner.appendChild div
      component.appendChild inner
      component.classList.add name, 'invisible'
    component

  # add event listenerss to buttons
  attachEventListeners: ->
    @button.addEventListener 'click', =>
      # cycle between active component states
      @next()
      @UpdateUI()

  ###*
   * [UpdateUI update the active text element]
   *
   * @method UpdateUI
   *
  ###
  UpdateUI: ->
    # reflect that the text was set forcefully
    @forced = true
    format = @active.type
    @color = new TinyColor @color
    alpha = false
    thisColor = null
    # fallback format to use when there is an alpha value
    fallbackAlphaFormat = atom.config.get 'chrome-color-picker.HexColors.fallbackAlphaFormat'
    # if the input format is hex but we have an alpha in the input, default to mr. muggles err rgb
    if @color.getAlpha() < 1
      alpha = true
      # trigger the fallback alpha format property on an alpha < 1
      if format is 'hex'
        format = fallbackAlphaFormat
        @changeFormat fallbackAlphaFormat

    # do something according with the format
    # hex
    if format is 'hex'
      input = @hex.querySelector 'atom-text-editor.hex'
      input.getModel().setText @color.toHexString()

    # rgb
    if format is 'rgb' or format is 'rgba'
      thisColor = @color.toRgb()
      input = @rgb.querySelector 'atom-text-editor.r'
      input.getModel().setText thisColor.r.toString()
      input = @rgb.querySelector 'atom-text-editor.g'
      input.getModel().setText thisColor.g.toString()
      input = @rgb.querySelector 'atom-text-editor.b'
      input.getModel().setText thisColor.b.toString()

    # toHsl
    if format is 'hsl' or format is 'hsla'
      thisColor = @color.toHsl()
      input = @hsl.querySelector 'atom-text-editor.h'
      input.getModel().setText Math.round(thisColor.h).toString()
      input = @hsl.querySelector 'atom-text-editor.s'
      input.getModel().setText "#{Math.round(thisColor.s * 100).toString()}%"
      input = @hsl.querySelector 'atom-text-editor.l'
      input.getModel().setText "#{Math.round(thisColor.l * 100).toString()}%"

    # if the alpha channel is present
    if alpha
      input = @[format].querySelector 'atom-text-editor.a'
      input.getModel().setText thisColor.a.toString()
      input.parentNode.removeAttribute 'style'
      @alpha = true
    else if format isnt 'hex'
      input = @[format].querySelector 'atom-text-editor.a'
      input.parentNode.setAttribute 'style', 'display: none'
      @alpha = false

  # change the current format to the one given
  changeFormat: (format) ->
    # convert all formats to the ones without the alpha channel
    format = format.replace('a', '')
    # hide all inputs
    for name in @formats
      @[name].classList.add 'invisible'
      @removeFocusable @[name].querySelector 'atom-text-editor'

    # set it active
    @active.type = format
    @active.component = @[format]
    # set active focusable to all inner inputs
    # converts NodeList to Array
    editorNodes = @[format].querySelectorAll 'atom-text-editor'
    # returns NodeList
    # https://developer.mozilla.org/en-US/docs/Web/API/NodeList
    editors = Array.from editorNodes
    for editor in editors
      @setFocusable editor
    # show the format
    @active.component.classList.remove 'invisible'
    @forced = true

  # sets the next component of the active array
  next: ->
    current = @formats.indexOf(@active.type)
    if current is (@formats.length - 1)
      current = 0
    else
      current++

    @changeFormat @formats[current]

  # return formated color in a string format
  getColor: ->
    # copy values
    color = @color.toString @active.type
    hexFormat = atom.config.get 'chrome-color-picker.HexColors.forceHexSize'
    rgbFormat = atom.config.get 'chrome-color-picker.RgbColors.preferredFormat'
    hslFormat = atom.config.get 'chrome-color-picker.HslColors.preferredFormat'
    hex3 = @color.toString('hex3')
    colorName = @color.toName()
    # if the color is rgb and needed to converted to a format
    if @active.type is 'rgb' and rgbFormat isnt 'standard'
      color = @color.toString rgbFormat
    # if the color is hsl and needed to converted to a format
    if @active.type is 'hsl' and hslFormat isnt 'standard'
      color = @color.toString hslFormat
    # if the color needs to be shortened and can be
    if @color.getAlpha() < 1 and atom.config.get 'chrome-color-picker.General.autoShortColor'
      # remove spaces
      color = color.replace(RegExp(' ', 'g'), '')
      # 0% => 0
      color = color.replace '0%', '0'
      # 1.0 => 1
      color = color.replace '1.0', '1'
      # 0. => .
      color = color.replace '0.', '.'
    # if uppercase color settings
    if @active.type is 'hex' and atom.config.get 'chrome-color-picker.HexColors.uppercaseHex'
      color = color.toUpperCase()
    # force hex format
    if @active.type is 'hex' and hexFormat
      hexForceColor = @color.toString(hexFormat)
      # if possible then do it
      if hexForceColor
        color = hexForceColor
    # if shortened hex settings
    if hex3 and atom.config.get 'chrome-color-picker.HexColors.autoShortHex'
      color = hex3
    # if color can be converted to a name and the user wants it then just do it
    if colorName and atom.config.get 'chrome-color-picker.General.autoColorNames'
      color = colorName
    color
