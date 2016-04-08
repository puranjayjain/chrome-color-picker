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

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:toggle': => @toggle()

  deactivate: ->
    @CCPContainer.destroy()
    @subscriptions.dispose()
    # @CCPView.destroy()

  serialize: ->
    # CCPViewState: @CCPView.serialize()

  toggle: ->
    @CCPContainer.toggle()

  addTooltips: ->
    @subscriptions.add atom.tooltips.add @CCPPastColor.component, {title: 'Previously set color'}
    @subscriptions.add atom.tooltips.add @CCPPresentColor.component, {title: 'Currently set color'}
    @subscriptions.add atom.tooltips.add @CCPContainerInput.active.button, {title: 'Cycle between colour modes'}
    @subscriptions.add atom.tooltips.add @CCPPalette.button, {title: 'Change color palette'}
    # add to material color palettes
    palettes = [{color: 'red', hex: ''}, {color: 'pink', hex: ''}, {color: 'purple', hex: ''}, {color: 'deep-purple', hex: ''}, {color: 'indigo', hex: ''}, {color: 'blue', hex: ''}, {color: 'light-blue', hex: ''}, {color: 'cyan', hex: ''}, {color: 'teal', hex: ''}, {color: 'green', hex: ''}, {color: 'light-green', hex: ''}, {color: 'lime', hex: ''}, {color: 'yellow', hex: ''}, {color: 'amber', hex: ''}, {color: 'orange', hex: ''}, {color: 'deep-orange', hex: ''}, {color: 'brown', hex: ''}, {color: 'grey', hex: ''}, {color: 'blue-grey', hex: ''}, {color: 'black', hex: ''}, {color: 'white']
    for palette in palettes
      console.log palette.color + ' ' + palette.hex + ' Click to select, Double Click to expand'
