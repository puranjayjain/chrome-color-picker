# ChromeColorPickerView = require './chrome-color-picker-view'
FloatingPanel = require './modules/ui/FloatingPanel'
InnerPanel = require './modules/ui/InnerPanel'

Swatch = require './modules/core/Swatch'
Slider = require './modules/core/Slider'

{CompositeDisposable} = require 'atom'

module.exports = ChromeColorPicker =
  ChromeColorPickerContainer: null
  ChromeColorPickerCanvas: null
  ChromeColorPickerControls: null
  ChromeColorPickerDisplay: null
  ChromeColorPickerPalette: null
  ChromeColorPickerPastColour: null
  ChromeColorPickerPresentColour: null
  ChromeColorPickerContainerSlider: null
  ChromeColorPickerSliderHue: null
  ChromeColorPickerSliderAlpha: null
  # chromeColorPickerView: null
  subscriptions: null

  activate: (state) ->
    # @chromeColorPickerView = new ChromeColorPickerView(state.chromeColorPickerViewState)
    # Initiate a new instance of the floating panel and add elements to it
    @ChromeColorPickerContainer = new FloatingPanel 'chrome-color-picker-container', document.querySelector 'atom-workspace-axis.vertical'
    @ChromeColorPickerCanvas = new InnerPanel 'chrome-color-picker-canvas'
    @ChromeColorPickerControls = new InnerPanel 'chrome-color-picker-panel'
    @ChromeColorPickerDisplay = new InnerPanel 'chrome-color-picker-panel', 'notop'
    @ChromeColorPickerPalette = new InnerPanel 'chrome-color-picker-panel'
    @ChromeColorPickerPastColour = new Swatch 'circle'
    @ChromeColorPickerPresentColour = new Swatch 'circle'
    @ChromeColorPickerContainerSlider = new InnerPanel 'chrome-color-picker-container-slider'
    @ChromeColorPickerSliderHue = new Slider 'hue'
    @ChromeColorPickerSliderAlpha = new Slider 'alpha'

    # Adding inner components to the panels
    @ChromeColorPickerControls.add @ChromeColorPickerPastColour
    @ChromeColorPickerControls.add @ChromeColorPickerPresentColour
    @ChromeColorPickerControls.add @ChromeColorPickerContainerSlider

    @ChromeColorPickerContainerSlider.add @ChromeColorPickerSliderHue
    @ChromeColorPickerContainerSlider.add @ChromeColorPickerSliderAlpha

    # Adding components to main container ... adding elements to other elements
    @ChromeColorPickerContainer.add @ChromeColorPickerCanvas
    @ChromeColorPickerContainer.add @ChromeColorPickerControls
    @ChromeColorPickerContainer.add @ChromeColorPickerDisplay
    @ChromeColorPickerContainer.add @ChromeColorPickerPalette

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:toggle': => @toggle()

  deactivate: ->
    @ChromeColorPickerContainer.destroy()
    @subscriptions.dispose()
    # @chromeColorPickerView.destroy()

  serialize: ->
    # chromeColorPickerViewState: @chromeColorPickerView.serialize()

  toggle: ->
    @ChromeColorPickerContainer.toggle()
