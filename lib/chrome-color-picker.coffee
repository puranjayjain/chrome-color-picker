# CCPView = require './chrome-color-picker-view'
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
  # CCPView: null

  OldColor: TinyColor().random().toHexString()
  NewColor: null

  subscriptions: null

  activate: (state) ->
    # copy values
    @NewColor = @OldColor

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # @CCPView = new CCPView(state.CCPViewState)
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
    # TODO pass it from settings saved
    # preferred output format can be RGB, HSL, VSL, etc.
    @CCPContainerInput = new Input @CCPDisplay.component, 'HEX'
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

    console.log @CCPDraggie

    # adding event handlers
    @attachEventListeners()

    # set initial color
    @CCPOldColor.setColor @OldColor
    @CCPNewColor.setColor @NewColor

    # Register commands for the keymaps
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:close': => @close()

  deactivate: ->
    @CCPContainer.destroy()
    @subscriptions.dispose()
    # @CCPView.destroy()

  serialize: ->
    # CCPViewState: @CCPView.serialize()

  toggle: ->
    @CCPContainer.toggle()

  close: ->
    @CCPContainer.close()

  addTooltips: ->
    @subscriptions.add atom.tooltips.add @CCPOldColor.component, {title: 'Previously set color'}
    @subscriptions.add atom.tooltips.add @CCPNewColor.component, {title: 'Currently set color'}
    @subscriptions.add atom.tooltips.add @CCPContainerInput.active.button, {title: 'Cycle between possible colour modes'}
    @subscriptions.add atom.tooltips.add @CCPPalette.customButton, {title: 'Add currently set colour to palette'}
    # TODO change them to relevant selected formats, the hex values
    # add to material color palettes
    palettes = @CCPPalette.swatches.materialPalette
    for palette, i in palettes
      @subscriptions.add atom.tooltips.add @CCPPalette.swatches.material[i], {title: palette.color + ' ' + palette.hex + ' Click to select, Double Click to expand'}

  # add event listeners to elements
  attachEventListeners: ->
    self = @

    # toggle the popup palette event from the bottom palette
    @CCPPalette.button.addEventListener 'click', ->
      self.togglePopUp()

    # toggle the popup palette event from the popup palette
    @CCPPalette.popUpPaletteButton.addEventListener 'click', ->
      self.togglePopUp()

    @CCPSliderHue.slider.addEventListener 'input', ->
      newColor = new TinyColor { h: (360 - @value), s: 100, v: 100 }
      self.CCPCanvas.setColor newColor.toHexString()
      self.CCPSliderAlpha.setColor newColor.toHexString()
      # hsvToRgb
      # newColor.h = (@value % 360) / 360;
      # console.log TinyColor 'hsv(' +  + ', 100%, 100%)'

  # toggle the popup palette function TODO dblclick
  togglePopUp: ->
    @CCPPalette.popUpPalette.classList.toggle 'invisible'
