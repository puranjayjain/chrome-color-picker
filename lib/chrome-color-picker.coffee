Config = require './config.coffee'

FloatingPanel = require './modules/ui/FloatingPanel'
InnerPanel = require './modules/ui/InnerPanel'

Swatch = require './modules/core/Swatch'
Slider = require './modules/core/Slider'
Input = require './modules/core/Input'
Palette = require './modules/core/Palette'

TinyColor = require './modules/helper/TinyColor.coffee'
Draggabilly = require './modules/helper/Draggabilly.coffee'

{CompositeDisposable} = require 'atom'

module.exports = CCP =
  # load default config and settings page
  config: Config

  # variables for use in plugin's UI
  CCPContainer: null
  CCPCanvas: null
  CCPCanvasOverlay: null
  CCPHandle: null
  CCPDraggie: null
  CCPDragger: null
  CCPControls: null
  CCPDisplay: null
  CCPContainerPalette: null
  CCPOldColor: null
  CCPNewColor: null
  CCPContainerSlider: null
  CCPSliderHue: null
  CCPSliderAlpha: null
  CCPContainerInput: null
  CCPPalette: null
  CCPActiveSwatch: null
  CCPSwatchPopup: null
  CCPOverlay: null

  # REVIEW change this function to pick a color if the pattern is not found
  OldColor: TinyColor().random()
  NewColor: null

  # TODO pass it from settings saved
  # preferred output format can be hex, hsl, rgb, etc.
  preferredFormat: 'hex'

  subscriptions: null

  activate: (state) ->
    # copy values
    @NewColor = @OldColor

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Initiate a new instance of the floating panel and add elements to it
    @CCPContainer = new FloatingPanel 'ccp-container', document.querySelector 'atom-workspace-axis.vertical'
    @CCPCanvas = new InnerPanel 'ccp-canvas'
    @CCPCanvasOverlay = new InnerPanel 'ccp-canvas-overlay'
    @CCPHandle = new InnerPanel 'ccp-handle'
    @CCPDragger = new InnerPanel 'ccp-dragger'
    @CCPControls = new InnerPanel 'ccp-panel'
    @CCPDisplay = new InnerPanel 'ccp-panel', 'notop'
    @CCPContainerPalette = new InnerPanel 'ccp-panel'
    @CCPOldColor = new Swatch 'circle'
    @CCPNewColor = new Swatch 'circle'
    @CCPContainerSlider = new InnerPanel 'ccp-container-slider'
    @CCPSliderHue = new Slider 'hue'
    @CCPSliderAlpha = new Slider 'alpha'
    @CCPContainerInput = new Input @CCPDisplay.component, @preferredFormat
    @CCPPalette = new Palette

    # add properties and attributes to some of them
    @CCPSliderHue.setMax 360
    @CCPSliderHue.setValue 0
    @CCPSliderAlpha.setValue 100

    @CCPContainerPalette.addClass 'palette'

    # Add tooltips to the relevant components
    @addTooltips()

    # Adding inner components to the panels
    @CCPDragger.add @CCPHandle

    @CCPCanvasOverlay.add @CCPDragger

    @CCPCanvas.add @CCPCanvasOverlay

    @CCPControls.add @CCPOldColor
    @CCPControls.add @CCPNewColor
    @CCPControls.add @CCPContainerSlider

    @CCPContainerSlider.add @CCPSliderHue
    @CCPContainerSlider.add @CCPSliderAlpha

    @CCPContainerPalette.add @CCPPalette
    @CCPContainerPalette.component.appendChild @CCPPalette.button

    # Adding components to main container ... adding elements to other elements
    @CCPContainer.add @CCPCanvas
    @CCPContainer.add @CCPControls
    @CCPContainer.add @CCPDisplay
    @CCPContainer.add @CCPContainerPalette
    @CCPContainer.component.appendChild @CCPPalette.popUpPalette

    # init draggabilly
    @CCPDraggie = new Draggabilly(@CCPDragger.component,
    containment: true
    handle: 'ccp-handle')

    # adding event handlers
    @attachEventListeners()

    # Register commands for the keymaps
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:close': => @close()

  deactivate: ->
    @CCPContainer.destroy()
    @subscriptions.dispose()

  serialize: ->
    # CCPViewState: @CCPView.serialize()

  toggle: ->
    @CCPContainer.toggle()
    # REVIEW change this logic to happen only on dialog open
    @UpdateUI color: @NewColor, old: true

    # close other stuff if already open
    if @CCPSwatchPopup?
      @CCPSwatchPopup.component.parentNode.removeChild @CCPSwatchPopup.component
      @CCPSwatchPopup = null
    if @CCPOverlay?
      @CCPOverlay.component.parentNode.removeChild @CCPOverlay.component
      @CCPOverlay = null
    # hide popUpPalette if visible
    if not @CCPPalette.popUpPalette.classList.contains 'invisible'
      @CCPPalette.popUpPalette.classList.add 'invisible'

  close: ->
    @CCPContainer.close()

  addTooltips: ->
    @subscriptions.add atom.tooltips.add @CCPOldColor.component, {title: 'Previously set color'}
    @subscriptions.add atom.tooltips.add @CCPNewColor.component, {title: 'Currently set color'}
    @subscriptions.add atom.tooltips.add @CCPContainerInput.button, {title: 'Cycle between possible color modes'}
    @subscriptions.add atom.tooltips.add @CCPPalette.customButton, {title: 'Add currently set color to palette'}
    # TODO change them to relevant selected formats, the hex values
    # add to material color palettes
    palettes = @CCPPalette.swatches.materialPalette
    for palette, i in palettes
      @subscriptions.add atom.tooltips.add @CCPPalette.swatches.material[i], {title: palette.color + ' ' + palette.hex + ' Click to select, Double Click to expand'}

  # add event listeners to elements
  attachEventListeners: ->
    self = @

    # main dialog close on escape key
    @CCPContainer.component.addEventListener 'keydown', (e) ->
      # Should do nothing if the key event was already consumed.
      if e.defaultPrevented
        return

      # if the new api is supported or the old one get the code
      code = if e.keyCode then e.keyCode else e.code
      if code is 27
        # close the dialog if the escape key is pressed
        self.toggle()
      # Consume the event for suppressing "double action".
      e.preventDefault()

    # click on the main slider
    @CCPCanvasOverlay.component.addEventListener 'click', (e) ->
      if not (e.target.nodeName is 'CCP-DRAGGER' or e.target.nodeName is 'CCP-HANDLE')
        x = e.offsetX / 239
        y = (124 - e.offsetY) / 124
        self.UpdateSlider x, y
      e.stopPropagation()

    # control the main slider
    @CCPDraggie.on 'dragMove', (event, pointer, moveVector) ->
      x = @position.x / 239
      y = (124 - @position.y)/124
      self.UpdateSlider x, y, false

    # slide the main slider using mouse wheel
    @CCPCanvasOverlay.component.addEventListener 'wheel', (e) ->
      delta = 5 * Math.sign e.wheelDelta
      # load initial values
      x = parseInt self.CCPDragger.component.offsetLeft
      y = 124 - parseInt self.CCPDragger.component.offsetTop
      # if the ctrl key was down
      if e.ctrlKey
        delta *= 2
      # if the shift key is down
      # add delta to
      if e.shiftKey
        x += delta
      else
        y += delta
      # if the value is less than the min cap it to min
      if x < 0
        x = 0
      if y < 0
        y = 0
      # if the value is greater than the max cap it to max
      if y > 124
        y = 124
      if x > 239
        x = 239
      # bring them to fractions
      x /= 239
      y /= 124
      # update the slider's position and value
      self.UpdateSlider x, y

    # click on old swatch to replace the new swatch with the color
    @CCPOldColor.component.addEventListener 'click', ->
      self.UpdateUI color: self.OldColor

    @CCPSliderHue.slider.addEventListener 'input', ->
      self.UpdateHue @value

    @CCPSliderAlpha.slider.addEventListener 'input', ->
      self.UpdateAlpha @value

    # mouse wheel events for hue and alpha
    @CCPSliderHue.slider.addEventListener 'wheel', (e) ->
      delta = Math.sign e.wheelDelta
      # if the ctrl key was down
      if e.ctrlKey
        delta *= 10
      newValue = parseInt @value
      newValue += delta
      # if the value is less than the min cap it to min
      if newValue < 0
        newValue = 0
      # if the value is greater than the max cap it to max
      if newValue > 360
        newValue = 360
      # update the slider with the new value
      @value = newValue
      # update color
      self.UpdateHue @value

    @CCPSliderAlpha.slider.addEventListener 'wheel', (e) ->
      delta = Math.sign e.wheelDelta
      # if the ctrl key was down
      if e.ctrlKey
        delta *= 10
      newValue = parseInt @value
      newValue += delta
      # if the value is less than the min cap it to min
      if newValue < 0
        newValue = 0
      # if the value is greater than the max cap it to max
      if newValue > 100
        newValue = 100
      # update the slider with the new value
      @value = newValue
      # update color
      self.UpdateAlpha @value

    # toggle the popup palette event from the bottom palette
    @CCPPalette.button.addEventListener 'click', ->
      self.togglePopUp()

    # toggle the popup palette event from the popup palette
    @CCPPalette.popUpPaletteButton.addEventListener 'click', ->
      self.togglePopUp()

    # bottom palette swatch click
    @CCPContainerPalette.component.addEventListener 'click', (e) ->
      if e.target and e.target.nodeName is 'CCP-SWATCH'
        newColor = new TinyColor e.target.getAttribute 'data-color'
        self.UpdateUI color: newColor

    # double click to open additional palettes
    @CCPContainerPalette.component.addEventListener 'dblclick', (e) ->
      if e.target and e.target.nodeName is 'CCP-SWATCH'
        # set this swatch as active
        self.CCPActiveSwatch = e.target
        # color weights
        weights = ['50', '100', '200', '300', '400','500', '600', '700', '800', '900', 'A100', 'A200', 'A400', 'A700']
        # add the popup palette
        self.CCPSwatchPopup = new InnerPanel 'ccp-swatch-popup'
        self.CCPOverlay = new InnerPanel 'ccp-overlay'
        # add eventlistener to close the palette on click of overlay
        self.CCPOverlay.component.addEventListener 'click', () ->
          @.parentNode.removeChild @
          self.CCPSwatchPopup.component.parentNode.removeChild self.CCPSwatchPopup.component
          self.CCPOverlay = null
          self.CCPSwatchPopup = null

        # create the palette with swatches
        colorName = e.target.getAttribute 'data-name'.toLowerCase()
        if colorName.indexOf '-' > -1
          colorName = colorName.replace '-', ''
        palette = self.CCPPalette.materialColors[colorName]
        docfrag = document.createDocumentFragment()
        i = palette.length
        while i--
          swatch = new Swatch 'square'
          swatch.component.setAttribute 'data-color', palette[i]
          swatch.component.setAttribute 'data-name', weights[i]
          swatch.component.setAttribute 'style', 'background: ' + palette[i]
          self.subscriptions.add atom.tooltips.add swatch.component, {title: e.target.getAttribute('data-name') + '(' + weights[i] + '): ' + palette[i] }
          docfrag.appendChild swatch.component
        self.CCPSwatchPopup.component.appendChild docfrag
        # position the popup correctly
        left = e.target.offsetLeft - 5
        bottom = self.CCPContainer.component.offsetHeight - e.target.offsetHeight - e.target.offsetTop - 5
        self.CCPSwatchPopup.component.setAttribute 'style', 'left: ' + left + 'px; bottom: ' + bottom + 'px'
        # add event listener to overlay
        self.CCPSwatchPopup.component.addEventListener 'click', (e) ->
          if e.target and e.target.nodeName is 'CCP-SWATCH'
            # set color
            newColor = new TinyColor e.target.getAttribute 'data-color'
            self.UpdateUI color: newColor
            # hide the component again
            self.CCPSwatchPopup.component.parentNode.removeChild self.CCPSwatchPopup.component
            self.CCPOverlay.component.parentNode.removeChild self.CCPOverlay.component
            self.CCPSwatchPopup = null
            self.CCPOverlay = null

        # attach overlay to main element
        self.CCPContainer.add self.CCPOverlay
        self.CCPContainer.add self.CCPSwatchPopup

    @CCPPalette.customButton.addEventListener 'click', () ->
      # add a new swatch with new color
      swatch = new Swatch 'square'
      swatch.component.setAttribute 'style', 'background: ' + self.NewColor.toRgbString()
      swatch.component.setAttribute 'data-color', self.NewColor.toRgbString()
      @parentNode.appendChild swatch.component

  # toggle the popup palette function TODO dblclick
  togglePopUp: ->
    @CCPPalette.popUpPalette.classList.toggle 'invisible'

  # Update UI from color - from spectrum.js
  # if old = true then update the old color swatch as well
  UpdateUI: ({color, old, slider, hue, alpha} = {}) ->
    old = if old? then old else false
    slider = if slider? then slider else true
    hue = if hue? then hue else true
    alpha = if alpha? then alpha else true
    @NewColor = color

    # set initial color
    if old
      @CCPOldColor.setColor @OldColor.toRgbString()
    @CCPNewColor.setColor @NewColor.toRgbString()

    hsvColor = @NewColor.toHsv()
    # update the top level spectrum's drag
    if slider
      @CCPDraggie.disable()
      @CCPDragger.setPosition Math.round(hsvColor.s * 239), 124 - Math.round(hsvColor.v * 124)
      @CCPDraggie.enable()

    # update the color of spectrum
    @CCPCanvas.setColor TinyColor({h: hsvColor.h, s: 1, v: 1}).toRgbString()
    # update the hue slider's value
    if hue
      @CCPSliderHue.setValue 360 - hsvColor.h
    # Update the alpha slider's color
    if alpha
      @CCPSliderAlpha.setColor TinyColor({h: hsvColor.h, s: 1, v: 1}).toRgbString()
      @CCPSliderAlpha.setValue Math.round hsvColor.a * 100
    # Update the display text
    @CCPContainerInput.color = @NewColor
    @CCPContainerInput.UpdateUI()

  # Update the color from the main slider and itself
  UpdateSlider: (x, y, s = true) ->
    oldColor = @NewColor.toHsv()
    newColor = new TinyColor { h: oldColor.h, s: x, v: y, a: oldColor.a }
    @UpdateUI color: newColor, slider: s

  # Update just the hue from the slider
  UpdateHue: (value) ->
    oldColor = @NewColor.toHsv()
    newColor = new TinyColor { h: (360 - value), s: oldColor.s, v: oldColor.v, a: oldColor.a }
    @UpdateUI color: newColor, hue: false

  # Update just the alpha from the slider
  UpdateAlpha: (value) ->
    oldColor = @NewColor.toHsv()
    newColor = new TinyColor { h: oldColor.h, s: oldColor.s, v: oldColor.v, a: value / 100 }
    @UpdateUI color: newColor, alpha: false
