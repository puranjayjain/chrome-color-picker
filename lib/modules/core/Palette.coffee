helper = require '../helper/helper.coffee'
InnerPanel = require '../ui/InnerPanel.coffee'
Swatch = require './Swatch.coffee'

module.exports =
class Palette extends helper

  ###*
   * [constructor Palette in atom]
   *
   * @method constructor
   *
   * @return {[type]}    [description]
  ###
  constructor: ->
    # create a custom element for the inner panel if not already done
    @component = @createComponent 'ccp-palette-inner'

    # add custom values and references here
    @swatches = {}

    # attach a button to the right side by the main ui
    @button = document.createElement 'BUTTON'
    @button.classList.add 'btn', 'btn-primary', 'btn-sm', 'icon', 'icon-chevron-up'

    # initiate and reference them so that they can be attached by the main ui
    @component.appendChild @initMaterial().component
    @popUpPaletteButton = null
    @popUpPalette = @initPopupPalette()

    # add event listeners to them
    @attachEventListeners()

  # create the material design Palette
  initMaterial: ->
    material = new InnerPanel 'ccp-panel-inner', 'material'

    # swatch material palette
    @swatches.materialPalette = [{color: 'Red', hex: '#F44336'}, {color: 'Pink', hex: '#E91E63'}, {color: 'Purple', hex: '#9C27B0'}, {color: 'Deep-purple', hex: '#673AB7'}, {color: 'Indigo', hex: '#3F51B5'}, {color: 'Blue', hex: '#2196F3'}, {color: 'Light-blue', hex: '#03A9F4'}, {color: 'Cyan', hex: '#00BCD4'}, {color: 'Teal', hex: '#009688'}, {color: 'Green', hex: '#4CAF50'}, {color: 'Light-green', hex: '#8BC34A'}, {color: 'Lime', hex: '#CDDC39'}, {color: 'Yellow', hex: '#FFEB3B'}, {color: 'Amber', hex: '#FFC107'}, {color: 'Orange', hex: '#FF9800'}, {color: 'Deep-orange', hex: '#FF5722'}, {color: 'Brown', hex: '#795548'}, {color: 'Grey', hex: '#9E9E9E'}, {color: 'Blue-grey', hex: '#607D8B'}, {color: 'Black', hex: '#000'}, {color: 'White', hex: '#fff'}]

    @swatches.material = []
    for n in [1..21]
      swatch = new Swatch 'square'
      swatch.component.setAttribute 'data-color', @swatches.materialPalette[n - 1].hex
      @swatches.material.push swatch.component
      material.component.appendChild swatch.component
    material

  # create the empty custom Palette
  initCustom: ->
    # body...

  # create the page's Palette
  # TODO make this feature
  # create the project's Palette
  # TODO make this feature

  # create the page popup palette
  initPopupPalette: ->
    popUpPalette = @createComponent 'ccp-palette-popup'
    panel1 = new InnerPanel 'ccp-panel'
    panel2 = new InnerPanel 'ccp-panel'
    panel3 = new InnerPanel 'ccp-panel'

    # hide popUpPalette
    popUpPalette.classList.add 'invisible'

    panel2.addClass 'material'
    panel3.addClass 'custom'

    # create internal structures of the panels
    h_panel1 = document.createElement 'H3'
    @popUpPaletteButton = document.createElement 'BUTTON'
    h_panel2 = document.createElement 'DIV'
    h_panel3 = document.createElement 'DIV'
    h_panel1.textContent = 'Color Palettes'
    @popUpPaletteButton.classList.add 'btn', 'btn-error', 'btn-sm', 'icon', 'icon-x'
    h_panel2.textContent = 'Material'
    h_panel3.textContent = 'Custom'

    # attach them to the panels
    panel1.component.appendChild h_panel1
    panel1.component.appendChild @popUpPaletteButton
    panel2.component.appendChild h_panel2
    panel3.component.appendChild h_panel3

    # attach swatches
    for n in [1..5]
      swatch = new Swatch 'square'
      panel2.component.appendChild swatch.component
      swatch = new Swatch 'square'
      panel3.component.appendChild swatch.component

    # attach them to the popUpPalette
    popUpPalette.appendChild panel1.component
    popUpPalette.appendChild panel2.component
    popUpPalette.appendChild panel3.component
    popUpPalette

  # add event listeners to elements
  attachEventListeners: ->
    # the bottom palette
    @component.addEventListener 'click', (e) ->
      if e.target and e.target.nodeName is 'CCP-SWATCH'
        console.log e.target.getAttribute 'data-color'
