# CCPView = require './chrome-color-picker-view'
FloatingPanel = require './modules/ui/FloatingPanel'
InnerPanel = require './modules/ui/InnerPanel'

Swatch = require './modules/core/Swatch'
Slider = require './modules/core/Slider'
Input = require './modules/core/Input'

{CompositeDisposable} = require 'atom'

module.exports = CCP =
  CCPContainer: null
  CCPCanvas: null
  CCPControls: null
  CCPDisplay: null
  CCPPalette: null
  CCPPastColor: null
  CCPPresentColor: null
  CCPContainerSlider: null
  CCPSliderHue: null
  CCPSliderAlpha: null
  CCPContainerInput: null
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
    @CCPPalette = new InnerPanel 'ccp-panel'
    @CCPPastColor = new Swatch 'circle'
    @subscriptions.add atom.tooltips.add @CCPPastColor.component, {title: 'Previously set color'}
    @CCPPresentColor = new Swatch 'circle'
    @subscriptions.add atom.tooltips.add @CCPPresentColor.component, {title: 'Currently set color'}
    @CCPContainerSlider = new InnerPanel 'ccp-container-slider'
    @CCPSliderHue = new Slider 'hue'
    @CCPSliderAlpha = new Slider 'alpha'
    # TODO pass it from settings saved
    # preferred output format can be RGB, HSL, VSL, etc.
    @CCPContainerInput = new Input @CCPDisplay.component, 'HEX'

    # Adding inner components to the panels
    @CCPControls.add @CCPPastColor
    @CCPControls.add @CCPPresentColor
    @CCPControls.add @CCPContainerSlider

    @CCPContainerSlider.add @CCPSliderHue
    @CCPContainerSlider.add @CCPSliderAlpha

    # Adding components to main container ... adding elements to other elements
    @CCPContainer.add @CCPCanvas
    @CCPContainer.add @CCPControls
    @CCPContainer.add @CCPDisplay
    @CCPContainer.add @CCPPalette

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
