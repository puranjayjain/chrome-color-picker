ChromeColorPickerView = require './chrome-color-picker-view'
FloatingPanel = require './modules/ui/FloatingPanel'
{CompositeDisposable} = require 'atom'

module.exports = ChromeColorPicker =
  ChromeColorPickerContainer: null
  chromeColorPickerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # @chromeColorPickerView = new ChromeColorPickerView(state.chromeColorPickerViewState)
    # @modalPanel = atom.workspace.addModalPanel(item: @chromeColorPickerView.getElement(), visible: false)
    @ChromeColorPickerContainer = new FloatingPanel('chrome-color-picker-container', 'atom-workspace-axis.vertical', 'invisible')
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @chromeColorPickerView.destroy()

  serialize: ->
    chromeColorPickerViewState: @chromeColorPickerView.serialize()

  toggle: ->
    @ChromeColorPickerContainer.toggle()
