# CCPView = require './chrome-color-picker-view'
FloatingPanel = require './modules/ui/FloatingPanel'
InnerPanel = require './modules/ui/InnerPanel'

Swatch = require './modules/core/Swatch'
Slider = require './modules/core/Slider'
Input = require './modules/core/Input'
Palette = require './modules/core/Palette'

{CompositeDisposable} = require 'atom'

module.exports = CCP =
  CCPContainer: null
  CCPCanvas: null
  CCPControls: null
  CCPDisplay: null
  CCPContainerPalette: null
  CCPPastColor: null
  CCPPresentColor: null
  CCPContainerSlider: null
  CCPSliderHue: null
  CCPSliderAlpha: null
  CCPContainerInput: null
  CCPPalette: null
  # CCPView: null

  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # @CCPView = new CCPView(state.CCPViewState)
    # Initiate a new instance of the floating panel and add elements to it
    @CCPContainer = new FloatingPanel 'ccp-container', document.querySelector 'atom-workspace-axis.vertical'
    @CCPCanvas = new InnerPanel 'ccp-canvas'
    @CCPControls = new InnerPanel 'ccp-panel'
    @CCPDisplay = new InnerPanel 'ccp-panel', 'notop'
    @CCPContainerPalette = new InnerPanel 'ccp-panel'
    @CCPPastColor = new Swatch 'circle'
    @CCPPresentColor = new Swatch 'circle'
    @CCPContainerSlider = new InnerPanel 'ccp-container-slider'
    @CCPSliderHue = new Slider 'hue'
    @CCPSliderAlpha = new Slider 'alpha'
    # TODO pass it from settings saved
    # preferred output format can be RGB, HSL, VSL, etc.
    @CCPContainerInput = new Input @CCPDisplay.component, 'HEX'
    @CCPPalette = new Palette

    # Add tooltips to the relevant components
    @addTooltips()

    # Adding inner components to the panels
    @CCPControls.add @CCPPastColor
    @CCPControls.add @CCPPresentColor
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
    @subscriptions.add atom.tooltips.add @CCPPastColor.component, {title: 'Previously set color'}
    @subscriptions.add atom.tooltips.add @CCPPresentColor.component, {title: 'Currently set color'}
    @subscriptions.add atom.tooltips.add @CCPContainerInput.active.button, {title: 'Cycle between colour modes'}
    @subscriptions.add atom.tooltips.add @CCPPalette.button, {title: 'Change color palette'}
    # TODO change them to relevant selected formats, the hex values
    # add to material color palettes
    palettes = [{color: 'Red', hex: '#F44336'}, {color: 'Pink', hex: '#E91E63'}, {color: 'Purple', hex: '#9C27B0'}, {color: 'Deep-purple', hex: '#673AB7'}, {color: 'Indigo', hex: '#3F51B5'}, {color: 'Blue', hex: '#2196F3'}, {color: 'Light-blue', hex: '#03A9F4'}, {color: 'Cyan', hex: '#00BCD4'}, {color: 'Teal', hex: '#009688'}, {color: 'Green', hex: '#4CAF50'}, {color: 'Light-green', hex: '#8BC34A'}, {color: 'Lime', hex: '#CDDC39'}, {color: 'Yellow', hex: '#FFEB3B'}, {color: 'Amber', hex: '#FFC107'}, {color: 'Orange', hex: '#FF9800'}, {color: 'Deep-orange', hex: '#FF5722'}, {color: 'Brown', hex: '#795548'}, {color: 'Grey', hex: '#9E9E9E'}, {color: 'Blue-grey', hex: '#607D8B'}, {color: 'Black', hex: '#000'}, {color: 'White', hex: '#fff'}]
    for palette, i in palettes
      @subscriptions.add atom.tooltips.add @CCPPalette.swatches.material[i], {title: palette.color + ' ' + palette.hex + ' Click to select, Double Click to expand'}
