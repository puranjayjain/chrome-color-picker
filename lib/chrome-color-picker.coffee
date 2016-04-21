Config = require './config'

FloatingPanel = require './modules/ui/FloatingPanel'
InnerPanel = require './modules/ui/InnerPanel'

Swatch = require './modules/core/Swatch'
Slider = require './modules/core/Slider'
Input = require './modules/core/Input'
Palette = require './modules/core/Palette'

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

  ColorMatcher: null
  OldColor: null
  NewColor: null
  Editor: null
  EditorView: null

  # to manage the disposable events and tooltips
  subscriptions: null
  popUpSubscriptions: null
  keyboardSubscriptions:null

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
    @CCPOldColor = new Swatch 'circle'
    @CCPNewColor = new Swatch 'circle'
    @CCPContainerSlider = new InnerPanel 'ccp-container-slider'
    @CCPSliderHue = new Slider 'hue'
    @CCPSliderAlpha = new Slider 'alpha'
    @CCPContainerInput = new Input @CCPDisplay.component
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
    @subscriptions.add atom.commands.add 'atom-workspace', 'chrome-color-picker:save': => @save()

  deactivate: ->
    @CCPContainer.destroy()
    @subscriptions.dispose()

  serialize: ->
    # CCPViewState: @CCPView.serialize()

  # save the dialog if open
  close: ->
    if @open
      @toggle()

  # save the color value if the dialog is open
  save: ->
    if @open
      @Editor.insertText @CCPContainerInput.getColor().toString()

  toggle: ->
    # check if the dialog is openable
    if @open
      @CCPContainer.toggle()
      # dispose temp events
      @keyboardSubscriptions.dispose()
      # focus the editor back
      @EditorView.focus()
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
      @EditorRoot = @EditorView.shadowRoot

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
      # set the position of the dialog
      @CCPContainer.setPlace cursorPosition, @EditorRoot, @EditorView, match

      # set the format
      @CCPContainerInput.changeFormat preferredFormat
      # toggle open the dialog
      @CCPContainer.toggle()
      # update the visible color
      @UpdateUI color: @OldColor, old: true

      # close the swatch popup if open
      if @CCPSwatchPopup? or @CCPOverlay?
        @HidePopUpOverlay()
      # hide popUpPalette if visible
      if not @CCPPalette.popUpPalette.classList.contains 'invisible'
        @CCPPalette.popUpPalette.classList.add 'invisible'

      # add keyboard events
      @addKeyBoardEvents()

      # toggle the state of the dialog
      @open = true

  addTooltips: ->
    @subscriptions.add atom.tooltips.add @CCPOldColor.component, {title: 'Previously set color'}
    @subscriptions.add atom.tooltips.add @CCPNewColor.component, {title: 'Currently set color'}
    @subscriptions.add atom.tooltips.add @CCPContainerInput.button, {title: 'Cycle between possible color modes'}
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
      y = (124 - @CCPDraggie.position.y)/124
      @UpdateSlider x, y, false

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

    # mouse wheel events for hue and alpha
    @CCPSliderHue.slider.addEventListener 'wheel', (e) =>
      delta = Math.sign e.wheelDelta
      # if the ctrl key was down
      if e.ctrlKey
        delta *= 10
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
        weights = ['50', '100', '200', '300', '400','500', '600', '700', '800', '900', 'A100', 'A200', 'A400', 'A700']
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
          @popUpSubscriptions.add atom.tooltips.add swatch.component, {title: "#{e.target.getAttribute('data-name')}(#{weights[i]}): #{palette[i]}" }
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
      swatch = new Swatch 'square'
      swatch.component.setAttribute 'style', 'background: ' + @NewColor.toRgbString()
      swatch.component.setAttribute 'data-color', @NewColor.toRgbString()
      e.target.parentNode.appendChild swatch.component

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
    @subscriptions.add hexEditor.onDidStopChanging =>
      color = TinyColor(hexEditor.getText())
      # if the color is valid
      if color.isValid()
        @NewColor = color
        # if the text was set forcefully then dont do it
        @UpdateUI color: @NewColor, text: false, forced: @CCPContainerInput.forced
        @CCPContainerInput.forced = false

    for type, _editor of rgbEditor
      @subscriptions.add _editor.onDidStopChanging =>
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
          @UpdateUI color: @NewColor, text: false, forced: @CCPContainerInput.forced
          @CCPContainerInput.forced = false

    for type, _editor of hslEditor
      @subscriptions.add _editor.onDidStopChanging =>
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
          @UpdateUI color: @NewColor, text: false, forced: @CCPContainerInput.forced
          @CCPContainerInput.forced = false

  # add keybindings to close and open the editor
  addKeyBoardEvents: ->
    # create a disposable to get rid of later
    @keyboardSubscriptions = new CompositeDisposable
    # create the event to moniter
    @keyboardSubscriptions.add atom.keymaps.onDidMatchBinding (e) =>
      # if the escape key is pressed close
      if e.keystrokes is 'escape'
        @close()
      # if the enter key is pressed inside the picker close it
      if e.keystrokes is 'enter' and @inside e.keyboardEventTarget
        @save()

  togglePopUp: ->
    @CCPPalette.popUpPalette.classList.toggle 'invisible'

  ###*
   * [UpdateUI update the ui controls of the dialog]
   * @param {[type]} color  [the color to be updated with]
   * @param {[type]} old    [update the old color swatch as well]
   * @param {[type]} slider [update the main slider]
   * @param {[type]} hue    [update the hue slider]
   * @param {[type]} alpha  [update the alpha slider]
   * @param {[type]} text   [update the inner editors]
   * @param {[type]} forced  [if the updated was forced or not]
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
      # console.log 'init'
      @save()

  # Update the color from the main slider and itself
  UpdateSlider: (x, y, s = true) ->
    oldColor = @NewColor.toHsv()
    newColor = new TinyColor { h: oldColor.h, s: x, v: y, a: oldColor.a }
    @UpdateUI color: newColor, slider: s, forced: false

  # Update just the hue from the slider
  UpdateHue: (value) ->
    oldColor = @NewColor.toHsv()
    newColor = new TinyColor { h: (360 - value), s: oldColor.s, v: oldColor.v, a: oldColor.a }
    @UpdateUI color: newColor, hue: false, forced: false

  # Update just the alpha from the slider
  UpdateAlpha: (value) ->
    oldColor = @NewColor.toHsv()
    newColor = new TinyColor { h: oldColor.h, s: oldColor.s, v: oldColor.v, a: value / 100 }
    @UpdateUI color: newColor, alpha: false, forced: false

  # Hide popup and overlay
  HidePopUpOverlay: ->
    @CCPOverlay.delete()
    @CCPSwatchPopup.delete()
    @CCPSwatchPopup = null
    @CCPOverlay = null
    @popUpSubscriptions.dispose()

  # inside the ccp-panel
  inside: (child) ->
    @CCPContainer.component.contains(child)
