Config = require './config'

FloatingPanel = require './modules/ui/FloatingPanel'
InnerPanel = require './modules/ui/InnerPanel'
BottomButtons = require './modules/ui/BottomButtons'

Swatch = require './modules/core/Swatch'
Slider = require './modules/core/Slider'
Input = require './modules/core/Input'
Palette = require './modules/core/Palette'
Picker = require './modules/core/Picker'

FocusTrap = require './modules/helper/FocusTrap'
TinyColor = require './modules/helper/TinyColor'
Draggabilly = require './modules/helper/Draggabilly'

{CompositeDisposable} = require 'atom'

module.exports = CCP =
  # dialog state
  open: false
  selection: null

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
  CCPContainerBottomButtons: null
  CCPBottomButtons: null
  CCPPicker: null

  # Other States UI States
  ColorRange: null
  ColorMatcher: null
  OldColor: null
  NewColor: null
  OpenPopUpPalette: off
  Editor: null
  EditorView: null

  # to manage the disposable events and tooltips
  tempListeners: {}
  subscriptions: null
  popUpSubscriptions: null

  activate: (state) ->
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
    @CCPPicker = new Picker
    @CCPOldColor = new Swatch 'circle'
    @CCPOldColor.removeFocusable()
    @CCPNewColor = new Swatch 'circle'
    @CCPNewColor.deleteFocusable()
    @CCPContainerSlider = new InnerPanel 'ccp-container-slider'
    @CCPSliderHue = new Slider 'hue'
    @CCPSliderAlpha = new Slider 'alpha'
    @CCPContainerInput = new Input @CCPDisplay.component
    @CCPPalette = new Palette

    # add properties and attributes to some of them
    @CCPContainer.component.tabIndex = '0'

    @CCPDragger.setFocusable()

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

    @CCPControls.add @CCPPicker
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
    @CCPDraggie = new Draggabilly @CCPDragger.component,
    containment: true
    handle: 'ccp-handle'

    # adding event handlers
    @attachEventListeners()

    # Register commands for the keymaps
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:close': => @close()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:save': => @save()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:saveAndClose': => @save(true)
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:pickcolor': => @toggleColorPicker()

    # commands not useful to be called from command palette but are needed
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:copyColor': => @copyColor()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:pasteColor': => @pasteColor()
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:deleteColor': => @deleteColor()

    # create the dynamic context menus
    @subscriptions.add atom.contextMenu.add {
      'ccp-panel-inner.material ccp-swatch': [
        {
          'label': 'Copy Swatch'
          'command': 'chrome-color-picker:copyColor'
          'created': @registerContext
        }
      ]
    }

    # create the dynamic context menus
    @subscriptions.add atom.contextMenu.add {
      'ccp-panel-inner.custom': [
        {
          'label': 'Copy Swatch'
          'command': 'chrome-color-picker:copyColor'
          'created': @registerContext
        }
        {
          'label': 'Paste Swatch'
          'command': 'chrome-color-picker:pasteColor'
        }
        {
          'type': 'separator'
        }
        {
          'label': 'Delete Swatch'
          'command': 'chrome-color-picker:deleteColor'
        }
      ]
    }

    # create the dynamic context menus for popUpPalette
    @subscriptions.add atom.contextMenu.add {
      'ccp-swatch-popup ccp-swatch': [
        {
          'label': 'Copy Swatch'
          'command': 'chrome-color-picker:copyColor'
          'created': @registerContextPopUP
        }
      ]
    }

  deactivate: ->
    @subscriptions.dispose()
    @CCPContainer.destroy()

  serialize: ->
    # TODO serialize palettes
    # CCPViewState: @CCPView.serialize()

  # save the dialog if open
  close: ->
    if @open
      @toggle()

  # save the color value if the dialog is open
  save: (close) ->
    if @open
      @ColorRange = @Editor.insertText @CCPContainerInput.getColor().toString()
    if close
      @close()

  toggle: ->
    # check if the dialog is openable
    if @open
      @CCPContainer.toggle()
      # remove temp listeners
      @removeTempEvents()
      # delete the buttons if not required
      if @CCPBottomButtons? and not atom.config.get 'chrome-color-picker.General.showButtons'
        @CCPContainerBottomButtons.delete()
        @CCPBottomButtons = null
        @CCPContainerBottomButtons = null
      # focus the editor back
      @EditorView.focus()
      # remove focus trap
      FocusTrap.deactivate()
      # close the picker
      @CCPPicker.close()
      # toggle the state of the dialog
      @open = false
    else
      # if the dialog is being opened then do this
      @Editor = atom.workspace.getActiveTextEditor()

      # dont open on non editor windows
      return unless @Editor

      # get the editor's view (htmlelement)
      @EditorView = atom.views.getView @Editor
      # get the shadow root of the editor
      @EditorRoot = @EditorView.shadowRoot or @EditorView.querySelector '.editor-contents'
      # get the last cursor (assuming multiple cursors)
      Cursor = @Editor.getLastCursor()

      # dont open on no cursor match
      return unless Cursor

      # get the text buffer and true position
      visibleRowRange = @EditorView.getVisibleRowRange()
      cursorScreenRow = Cursor.getScreenRow()
      cursorBufferRow = Cursor.getBufferRow()

      # don't open the picker if the text is out of screen
      return if (cursorScreenRow < visibleRowRange[0]) or (cursorScreenRow > visibleRowRange[1])

      # Get the current buffer's line to match it for color
      BufferLine = Cursor.getCurrentBufferLine()

      # match them from tinycolor regex
      matches = TinyColor().getMatch BufferLine

      # get the current column from the buffer
      cursorColumn = Cursor.getBufferColumn()
      # REVIEW change this to something better performing like a negative while loop
      # IDEA try implementing https://atom.io/docs/api/v1.7.2/Cursor#instance-compare
      # Figure out which of the matches is the one the user wants
      match = do -> for _match in matches
        # select the match if in range
        return _match if _match.start <= cursorColumn and _match.end >= cursorColumn

      # select the match if found
      if match
        # clear any previous selection
        @Editor.clearSelections()

        # select the new color
        selection = @Editor.addSelectionForBufferRange [
          [cursorBufferRow, match.start]
          [cursorBufferRow, match.end]]

        # add to global selection for reference
        @selection = color: match, row: cursorBufferRow
      else
        # TODO change it to previous position
        # even if we don't have a match place it over the last line
        @selection = column: Cursor.getBufferColumn(), row: cursorBufferRow

      # get the Actual position of the Cursor
      cursorPosition = @EditorView.pixelRectForScreenRange @Editor.getSelectedScreenRange()
      @OldColor = if match then TinyColor(match.color) else TinyColor().random()
      @NewColor = @OldColor

      # change the format of the input
      preferredFormat = atom.config.get 'chrome-color-picker.General.preferredFormat'

      # pass the format if given as authored if found else pass hex
      preferredFormat = if preferredFormat is 'As authored' and !!match then match.format else 'hex'

      # show palette according to preference
      @CCPContainerInput.toggle.classList.remove 'icon-fold', 'icon-unfold'
      if atom.config.get 'chrome-color-picker.General.paletteOpen'
        @CCPContainerPalette.component.classList.remove 'invisible'
        @CCPContainerInput.toggle.classList.add 'icon-fold'
      else
        @CCPContainerPalette.component.classList.add 'invisible'
        @CCPContainerInput.toggle.classList.add 'icon-unfold'

      # set the position of the dialog
      @CCPContainer.setPlace cursorPosition, @EditorRoot, @EditorView, match

      # create the ok and cancel buttons if needed
      if not @CCPBottomButtons? and atom.config.get 'chrome-color-picker.General.showButtons'
        @CCPContainerBottomButtons = new InnerPanel 'ccp-panel', 'bottombuttons'
        @CCPBottomButtons = new BottomButtons @CCPContainerBottomButtons.component
        @CCPContainer.add @CCPContainerBottomButtons
        @addBottomButtonEvents()

      # set the format
      @CCPContainerInput.changeFormat preferredFormat

      # toggle open the dialog
      @CCPContainer.toggle()

      # activate focus trap
      @setTrap(@CCPContainer.component,
               @CCPContainer.component.querySelector('ccp-input:not(.invisible) atom-text-editor'))

      # update the visible color
      @UpdateUI color: @OldColor, old: true

      # close the swatch popup if open
      if @CCPSwatchPopup? or @CCPOverlay?
        @HidePopUpOverlay()
      # hide popUpPalette if visible
      if not @CCPPalette.popUpPalette.classList.contains 'invisible'
        @CCPPalette.popUpPalette.classList.add 'invisible'

      # add keyboard events
      @addTempEvents()

      # toggle the state of the dialog
      @open = true

  # HACK find a possible alternative to this method someone pls.
  registerContextPopUP: (e) ->
    # data element palette inner
    dataElement = document.getElementsByTagName('ccp-palette-inner')[0]

    # get nth child number of element
    getNthChild = (child) ->
      i = 0
      while (child = child.previousSibling)?
        i++
      ++i

    # get css path of element
    fullPath = (el) ->
      "#{el.parentNode.nodeName.toLowerCase()} #{el.nodeName.toLowerCase()}:nth-child(#{getNthChild(el)})"

    dataElement.setAttribute 'data-copy', e.target.getAttribute 'data-color'
    dataElement.setAttribute 'data-action2', fullPath e.target
    dataElement.setAttribute 'data-action', fullPath e.target

  # HACK find a possible alternative to this method someone pls.
  # register current swatch or element for reference
  registerContext: (e) ->
    # data element palette inner
    dataElement = document.getElementsByTagName('ccp-palette-inner')[0]

    # set paste element
    setPaste = (el) ->
      # to check the paste target later
      if el.nodeName is 'CCP-PANEL-INNER' and el.className is 'custom'
        dataElement.setAttribute 'data-paste', true

    # get nth child number of element
    getNthChild = (child) ->
      i = 0
      while (child = child.previousSibling)?
        i++
      ++i

    # get css path of element
    fullPath = (el) ->
      "#{el.parentNode.nodeName.toLowerCase()}.#{el.parentNode.className} #{el.nodeName.toLowerCase()}:nth-child(#{getNthChild(el)})"

    # set paste
    setPaste e.target

    # only register nodes with relevance
    if e.target.nodeName is 'CCP-SWATCH' and not dataElement.getAttribute 'data-action'
      dataElement.setAttribute 'data-action', fullPath e.target
    if e.target.nodeName is 'CCP-SWATCH'
      dataElement.setAttribute 'data-action2', fullPath e.target
      setPaste e.target.parentNode

  toggleColorPicker: ->
    if @open
      @CCPPicker.toggle()

  copyColor: ->
    # copy data action 2 to 1
    @CCPPalette.component.setAttribute 'data-action', @CCPPalette.component.getAttribute 'data-action2'
    # only do if the correct element is copied
    el = document.querySelector @CCPPalette.component.getAttribute('data-action')
    if el?
      if el.nodeName is 'CCP-SWATCH'
        # add reference to start work, for copy action
        @CCPPalette.component.setAttribute 'data-paste', true

  pasteColor: ->
    # also we are only pasting in custom palette
    if @CCPPalette.component.getAttribute 'data-paste'
      # get the element
      el = document.querySelector @CCPPalette.component.getAttribute 'data-action'

      # if not element but color then use it directly
      if el?
        color = el.getAttribute 'data-color'
      else
        color = @CCPPalette.component.getAttribute 'data-copy'

      # do only if there is an actual color
      if color?
        # add a new swatch with new color
        @CCPPalette.addSwatch color

  deleteColor: ->
    # copy data action 2 to 1
    @CCPPalette.component.setAttribute 'data-action', @CCPPalette.component.getAttribute 'data-action2'
    el = document.querySelector @CCPPalette.component.getAttribute 'data-action'
    if el?
      if el.nodeName is 'CCP-SWATCH' and el.parentNode.className is 'custom'
        # remove swatch
        el.parentNode.removeChild el
        # remove the references to avoid problems
        @CCPPalette.component.removeAttribute 'data-action'

  addTooltips: ->
    @subscriptions.add atom.tooltips.add @CCPPicker.component, {
      title: 'Toggle on / off the color picker'
      keyBindingCommand: 'chrome-color-picker:pickcolor'
      keyBindingTarget: @CCPContainer.component
    }
    @subscriptions.add atom.tooltips.add @CCPOldColor.component, {title: 'Previously set color'}
    @subscriptions.add atom.tooltips.add @CCPNewColor.component, {title: 'Currently set color'}
    @subscriptions.add atom.tooltips.add @CCPContainerInput.button, {title: 'Cycle between possible color modes'}
    @subscriptions.add atom.tooltips.add @CCPContainerInput.toggle, {title: 'Toggle open / close the palette'}
    @subscriptions.add atom.tooltips.add @CCPPalette.customButton, {title: 'Add currently set color to palette'}
    # add to material color palettes
    palettes = @CCPPalette.swatches.materialPalette
    for palette, i in palettes
      @subscriptions.add atom.tooltips.add @CCPPalette.swatches.material[i], {title: "#{palette.color} #{palette.hex} Click to select, Double Click to expand"}

  # add event listeners to elements
  attachEventListeners: ->
    # reference the global workspace
    workspace = atom.workspace
    # close dialog on various workspace events
    # close it when the active item is changed
    @subscriptions.add workspace.onDidChangeActivePaneItem => @close()

    # close it on scroll over the workspace
    atom.workspace.observeTextEditors (editor) =>
      editorView = atom.views.getView editor
      @subscriptions.add editorView.onDidChangeScrollTop => @close()
      @subscriptions.add editorView.onDidChangeScrollLeft => @close()

    # click on the main slider
    @CCPCanvasOverlay.component.addEventListener 'click', (e) =>
      if not (e.target.nodeName is 'CCP-DRAGGER' or e.target.nodeName is 'CCP-HANDLE')
        x = e.offsetX / 239
        y = (124 - e.offsetY) / 124
        @UpdateSlider x, y
      e.stopPropagation()

    # control the main slider
    @CCPDraggie.on 'dragMove', (e, p, m) =>
      x = @CCPDraggie.position.x / 239
      y = (124 - @CCPDraggie.position.y) / 124
      @UpdateSlider x, y, false

    # control the main slider using arrow keys
    @CCPDragger.component.addEventListener 'keydown', (e) =>
      # load initial values
      delta = 5
      x = parseInt @CCPDragger.component.offsetLeft
      y = 124 - parseInt @CCPDragger.component.offsetTop
      # set sign according to key
      if @isRightArrow e
        x += delta
      else if @isLeftArrow e
        x -= delta
      else if @isUpArrow e
        y += delta
      else if @isDownArrow e
        y -= delta
      else
        return
      # if the ctrl key was down
      if e.ctrlKey
        delta *= 2
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
      @UpdateSlider x, y

    # slide the main slider using mouse wheel
    @CCPCanvasOverlay.component.addEventListener 'wheel', (e) =>
      delta = 5 * Math.sign e.wheelDelta
      # load initial values
      x = parseInt @CCPDragger.component.offsetLeft
      y = 124 - parseInt @CCPDragger.component.offsetTop
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
      @UpdateSlider x, y

    # click on old swatch to replace the new swatch with the color
    @CCPOldColor.component.addEventListener 'click', =>
      @UpdateUI color: @OldColor

    @CCPSliderHue.slider.addEventListener 'input', (e) =>
      @UpdateHue e.target.value

    @CCPSliderAlpha.slider.addEventListener 'input', (e) =>
      @UpdateAlpha e.target.value

    @CCPSliderHue.slider.addEventListener 'keydown', (e) =>
      delta = 0
      if @isRightArrow e
        delta = 1
      else if @isLeftArrow e
        delta = -1
      else
        return
      # if the ctrl key was down
      if e.ctrlKey
        delta *= 10
      # get the original value from slider
      newValue = parseInt e.target.value
      newValue += delta
      # if the value is less than the min cap it to min
      if newValue < 0
        newValue = 0
      # if the value is greater than the max cap it to max
      if newValue > 360
        newValue = 360
      # update the slider with the new value
      e.target.value = newValue
      # update color
      @UpdateHue newValue

    # arrow key events for sliders
    @CCPSliderAlpha.slider.addEventListener 'keydown', (e) =>
      delta = 0
      if @isRightArrow e
        delta = 1
      else if @isLeftArrow e
        delta = -1
      else
        return
      # if the ctrl key was down
      if e.ctrlKey
        delta *= 10
      # get the original value from slider
      newValue = parseInt e.target.value
      newValue += delta
      # if the value is less than the min cap it to min
      if newValue < 0
        newValue = 0
      # if the value is greater than the max cap it to max
      if newValue > 100
        newValue = 100
      # update the slider with the new value
      e.target.value = newValue
      # update color
      @UpdateAlpha newValue

    # mouse wheel events for hue and alpha
    @CCPSliderHue.slider.addEventListener 'wheel', (e) =>
      delta = Math.sign e.wheelDelta
      # if the ctrl key was down
      if e.ctrlKey
        delta *= 10
      # get the original value from slider
      newValue = parseInt e.target.value
      newValue += delta
      # if the value is less than the min cap it to min
      if newValue < 0
        newValue = 0
      # if the value is greater than the max cap it to max
      if newValue > 360
        newValue = 360
      # update the slider with the new value
      e.target.value = newValue
      # update color
      @UpdateHue newValue

    @CCPSliderAlpha.slider.addEventListener 'wheel', (e) =>
      delta = Math.sign e.wheelDelta
      # if the ctrl key was down
      if e.ctrlKey
        delta *= 10
      # get the original value from slider
      newValue = parseInt e.target.value
      newValue += delta
      # if the value is less than the min cap it to min
      if newValue < 0
        newValue = 0
      # if the value is greater than the max cap it to max
      if newValue > 100
        newValue = 100
      # update the slider with the new value
      e.target.value = newValue
      # update color
      @UpdateAlpha newValue

    @CCPContainerInput.toggle.addEventListener 'click', =>
      # close or open the palette
      @CCPContainerPalette.component.classList.toggle 'invisible'
      # force toggle the state of the button
      if @CCPContainerInput.toggle.classList.contains 'icon-fold'
        @CCPContainerInput.toggle.classList.remove 'icon-fold'
        @CCPContainerInput.toggle.classList.add 'icon-unfold'
        atom.config.set 'chrome-color-picker.General.paletteOpen', false
      else
        @CCPContainerInput.toggle.classList.remove 'icon-unfold'
        @CCPContainerInput.toggle.classList.add 'icon-fold'
        atom.config.set 'chrome-color-picker.General.paletteOpen', true

    # toggle the popup palette event from the bottom palette
    @CCPPalette.button.addEventListener 'click', =>
      @togglePopUp()

    # toggle the popup palette event from the popup palette
    @CCPPalette.popUpPaletteButton.addEventListener 'click', =>
      @togglePopUp()

    # bottom palette swatch click
    @CCPContainerPalette.component.addEventListener 'click', (e) =>
      if e.target and e.target.nodeName is 'CCP-SWATCH'
        newColor = new TinyColor e.target.getAttribute 'data-color'
        @UpdateUI color: newColor, forced: false

    # double click to open additional palettes
    @CCPContainerPalette.component.addEventListener 'dblclick', (e) =>
      # open only for material palette
      # and it doesnt even matter if you are black or white
      if e.target and e.target.nodeName is 'CCP-SWATCH' and e.target.parentNode.classList.contains('material') and e.target.getAttribute('data-name') isnt 'black' and e.target.getAttribute('data-name') isnt 'white'
        # dispose off any previous tooltips
        if @popUpSubscriptions? then @popUpSubscriptions.dispose()
        # init the temp disposable
        @popUpSubscriptions = new CompositeDisposable
        # set this swatch as active
        @CCPActiveSwatch = e.target
        # color weights
        weights = ['50', '100', '200', '300', '400', '500', '600', '700', '800', '900', 'A100', 'A200', 'A400', 'A700']
        # add the popup palette
        @CCPSwatchPopup = new InnerPanel 'ccp-swatch-popup'
        @CCPOverlay = new InnerPanel 'ccp-overlay'
        # add eventlistener to close the palette on click of overlay
        @CCPOverlay.component.addEventListener 'click', =>
          @HidePopUpOverlay()

        # create the palette with swatches
        colorName = e.target.getAttribute 'data-name'.toLowerCase()
        if colorName.indexOf '-' > -1
          colorName = colorName.replace '-', ''
        palette = @CCPPalette.materialColors[colorName]
        docfrag = document.createDocumentFragment()
        i = palette.length
        while i--
          swatch = new Swatch 'square'
          swatch.component.setAttribute 'data-color', palette[i]
          swatch.component.setAttribute 'data-name', weights[i]
          swatch.component.setAttribute 'style', 'background: ' + palette[i]
          @popUpSubscriptions.add atom.tooltips.add swatch.component, {title: "#{e.target.getAttribute('data-name')}(#{weights[i]}): #{palette[i]}"}
          docfrag.appendChild swatch.component
        @CCPSwatchPopup.component.appendChild docfrag
        # position the popup correctly
        left = e.target.offsetLeft - 5
        bottom = @CCPContainer.component.offsetHeight - e.target.offsetHeight - e.target.offsetTop - 5
        @CCPSwatchPopup.component.setAttribute 'style', "left: #{left}px; bottom: #{bottom}px"
        # add event listener to overlay
        @CCPSwatchPopup.component.addEventListener 'click', (e) =>
          if e.target and e.target.nodeName is 'CCP-SWATCH'
            # set color
            newColor = new TinyColor e.target.getAttribute 'data-color'
            @UpdateUI color: newColor, forced: false
            # hide the component again
            @HidePopUpOverlay()

        # attach overlay to main element
        @CCPContainer.add @CCPOverlay
        @CCPContainer.add @CCPSwatchPopup

    @CCPPalette.customButton.addEventListener 'click', (e) =>
      # add a new swatch with new color
      @CCPPalette.addSwatch @NewColor

    # get all the editors
    hexEditor = @CCPContainerInput.hex.querySelector('atom-text-editor.hex').getModel()
    rgbEditor = {
      'r': @CCPContainerInput.rgb.querySelector('atom-text-editor.r').getModel()
      'g': @CCPContainerInput.rgb.querySelector('atom-text-editor.g').getModel()
      'b': @CCPContainerInput.rgb.querySelector('atom-text-editor.b').getModel()
      'a': @CCPContainerInput.rgb.querySelector('atom-text-editor.a').getModel()
    }
    hslEditor = {
      'h': @CCPContainerInput.hsl.querySelector('atom-text-editor.h').getModel()
      's': @CCPContainerInput.hsl.querySelector('atom-text-editor.s').getModel()
      'l': @CCPContainerInput.hsl.querySelector('atom-text-editor.l').getModel()
      'a': @CCPContainerInput.hsl.querySelector('atom-text-editor.a').getModel()
    }
    # events for text editor changes and delay them using stop changing to prevent rendering issues
    # replaced onDidStopChanging
    @subscriptions.add hexEditor.onDidInsertText =>
      color = TinyColor(hexEditor.getText())
      # if the color is valid
      if color.isValid()
        @NewColor = color
        # if the text was set forcefully then dont do it
        @UpdateUI color: @NewColor, text: false, forced: false

    for type, _editor of rgbEditor
      @subscriptions.add _editor.onDidInsertText =>
        color = TinyColor({
          r: rgbEditor.r.getText()
          g: rgbEditor.g.getText()
          b: rgbEditor.b.getText()
        })
        # set alpha if required
        if @CCPContainerInput.alpha
          color.setAlpha rgbEditor.a.getText()
        # if the color is valid
        if color.isValid()
          @NewColor = color
          # if the text was set forcefully then dont do it
          @UpdateUI color: @NewColor, text: false, forced: false

    for type, _editor of hslEditor
      @subscriptions.add _editor.onDidInsertText =>
        color = TinyColor({
          h: hslEditor.h.getText()
          s: hslEditor.s.getText()
          l: hslEditor.l.getText()
        })
        # set alpha if required
        if @CCPContainerInput.alpha
          color.setAlpha hslEditor.a.getText()
        # if the color is valid
        if color.isValid()
          @NewColor = color
          # if the text was set forcefully then dont do it
          @UpdateUI color: @NewColor, text: false, forced: false

    # attach event listeners to the popuppalettes


    @CCPPalette.panel2.component.addEventListener 'click', (e) =>
      # hide all palettes
      for key, value of @CCPPalette.palettes
        value.classList.add 'invisible'
      # unhide the one to use
      @CCPPalette.palettes[@CCPPalette.panel2.component.className].classList.remove 'invisible'
      # close the popup
      @togglePopUp()

    @CCPPalette.panel3.component.addEventListener 'click', (e) =>
      # hide all palettes
      for key, value of @CCPPalette.palettes
        value.classList.add 'invisible'
      # unhide the one to use
      @CCPPalette.palettes[@CCPPalette.panel3.component.className].classList.remove 'invisible'
      # close the popup
      @togglePopUp()

  # add bottom button events
  addBottomButtonEvents: ->
    @CCPBottomButtons.ok.addEventListener 'click', =>
      @save(true)

    @CCPBottomButtons.cancel.addEventListener 'click', =>
      @close()

  # add temporary events which attach and dettach on open/ close of the dialog
  addTempEvents: ->
    # event to close the dialog on click anywhere outside the dialog
    @tempListeners.onClick = (e) =>
      if not @inside e.target
        # if the picker is open then get the color and close just the picker
        if @CCPPicker.state
          @UpdateUI color: TinyColor @CCPPicker.color
          @CCPPicker.close()
        else
          @close()

    # event to close the dialog on atom resize
    @tempListeners.onResize = =>
      @close()

    # attach the events to the window
    window.addEventListener 'click', @tempListeners.onClick, true
    window.addEventListener 'resize', @tempListeners.onResize, true

  # remove event listeners
  removeTempEvents: ->
    window.removeEventListener 'click', @tempListeners.onClick, true
    window.removeEventListener 'resize', @tempListeners.onResize, true

  togglePopUp: ->
    @CCPPalette.popUpPalette.classList.toggle 'invisible'
    # if the popuppalette is visible then focus it else focus the main picker
    # deactivate the current one before activating a new one
    FocusTrap.deactivate()
    if @OpenPopUpPalette
      @setTrap(@CCPContainer.component,
               @CCPContainer.component.querySelector('ccp-input:not(.invisible) atom-text-editor'))
    else
      setTimeout (=>
        @setTrap(@CCPPalette.popUpPalette,
                 @CCPPalette.popUpPalette.querySelector('ccp-panel.material'))
      ), 100
    # toggle the state variable
    @OpenPopUpPalette = not @OpenPopUpPalette

  ###*
   * [UpdateUI update the ui controls of the dialog]
   * @param {[type]} color  [the color to be updated with]
   * @param {[type]} old    [update the old color swatch as well]
   * @param {[type]} slider [update the main slider]
   * @param {[type]} hue    [update the hue slider]
   * @param {[type]} alpha  [update the alpha slider]
   * @param {[type]} text   [update the inner editors]
   * @param {[type]} forced [if the updated was forced or not]
  ###
  UpdateUI: ({color, old, slider, hue, alpha, text, forced} = {}) ->
    # load the default values of the values
    old = if old? then old else false
    slider = if slider? then slider else true
    hue = if hue? then hue else true
    alpha = if alpha? then alpha else true
    text = if text? then text else true
    forced = if forced? then forced else true
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
    # Update text if it is wanted to be updated
    if text
      @CCPContainerInput.UpdateUI()
    # if the setting to change color as edit is being set then just do it also only do it for a selection
    if atom.config.get('chrome-color-picker.General.autoSetColor') and not forced
      @save()
      # add selection for the range
      selection = @Editor.addSelectionForBufferRange [
        [@ColorRange[0].start.row, @ColorRange[0].start.column]
        [@ColorRange[0].end.row, @ColorRange[0].end.column]
      ]

  # Update the color from the main slider and itself
  UpdateSlider: (x, y, s = true) ->
    oldColor = @NewColor.toHsv()
    newColor = new TinyColor {h: oldColor.h, s: x, v: y, a: oldColor.a}
    @UpdateUI color: newColor, slider: s, forced: false

  # Update just the hue from the slider
  UpdateHue: (value) ->
    oldColor = @NewColor.toHsv()
    newColor = new TinyColor {h: (360 - value), s: oldColor.s, v: oldColor.v, a: oldColor.a}
    @UpdateUI color: newColor, hue: false, forced: false

  # Update just the alpha from the slider
  UpdateAlpha: (value) ->
    oldColor = @NewColor.toHsv()
    newColor = new TinyColor {h: oldColor.h, s: oldColor.s, v: oldColor.v, a: value / 100}
    @UpdateUI color: newColor, alpha: false, forced: false

  # Hide popup and overlay
  HidePopUpOverlay: ->
    @CCPOverlay.delete()
    @CCPSwatchPopup.delete()
    @CCPSwatchPopup = null
    @CCPOverlay = null
    @popUpSubscriptions.dispose()

  # set main dialog focus trap
  setTrap: (el, initialFocus) ->
    FocusTrap.activate el,
      initialFocus: initialFocus
      onDeactivate: ->
        el.classList.remove 'is-active'
    # add classes to show the that the trap is activated
    el.classList.add 'trap'
    el.classList.add 'is-active'

  # inside the ccp-panel
  inside: (child) ->
    @CCPContainer.component.contains(child)

  # is left arrow key
  isLeftArrow: (e) ->
    e.key is 'ArrowLeft' or e.code is 'ArrowLeft' or e.keyCode is 37

  # is up arrow key
  isUpArrow: (e) ->
    e.key is 'ArrowUp' or e.code is 'ArrowUp' or e.keyCode is 38

  # is right arrow key
  isRightArrow: (e) ->
    e.key is 'ArrowRight' or e.code is 'ArrowRight' or e.keyCode is 39

  # is down arrow key
  isDownArrow: (e) ->
    e.key is 'ArrowDown' or e.code is 'ArrowDown' or e.keyCode is 40
