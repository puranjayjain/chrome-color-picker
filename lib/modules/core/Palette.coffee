helper = require '../helper/helper'
InnerPanel = require '../ui/InnerPanel'
Swatch = require './Swatch'
TinyColor = require '../helper/TinyColor'
JSTabber = require '../helper/JSTabber'

module.exports =
class Palette extends helper
  swatches: {}
  customButton: null
  popUpPalette: null
  popUpPaletteButton: null
  palettes: {}

  # all material palettes
  materialColors: {
    red: ['#ffebee', '#ffcdd2', '#ef9a9a', '#e57373', '#ef5350', '#f44336', '#e53935', '#d32f2f', '#c62828', '#b71c1c', '#ff8a80', '#ff5252', '#ff1744', '#d50000']
    pink: ['#fce4ec', '#f8bbd0', '#f48fb1', '#f06292', '#ec407a', '#e91e63', '#d81b60', '#c2185b', '#ad1457', '#880e4f', '#ff80ab', '#ff4081', '#f50057', '#c51162']
    purple: ['#f3e5f5', '#e1bee7', '#ce93d8', '#ba68c8', '#ab47bc', '#9c27b0', '#8e24aa', '#7b1fa2', '#6a1b9a', '#4a148c', '#ea80fc', '#e040fb', '#d500f9', '#aa00ff']
    deeppurple: ['#ede7f6', '#d1c4e9', '#b39ddb', '#9575cd', '#7e57c2', '#673ab7', '#5e35b1', '#512da8', '#4527a0', '#311b92', '#b388ff', '#7c4dff', '#651fff', '#6200ea']
    indigo: ['#e8eaf6', '#c5cae9', '#9fa8da', '#7986cb', '#5c6bc0', '#3f51b5', '#3949ab', '#303f9f', '#283593', '#1a237e', '#8c9eff', '#536dfe', '#3d5afe', '#304ffe']
    blue: ['#e3f2fd', '#bbdefb', '#90caf9', '#64b5f6', '#42a5f5', '#2196f3', '#1e88e5', '#1976d2', '#1565c0', '#0d47a1', '#82b1ff', '#448aff', '#2979ff', '#2962ff']
    lightblue: ['#e1f5fe', '#b3e5fc', '#81d4fa', '#4fc3f7', '#29b6f6', '#03a9f4', '#039be5', '#0288d1', '#0277bd', '#01579b', '#80d8ff', '#40c4ff', '#00b0ff', '#0091ea']
    cyan: ['#e0f7fa', '#b2ebf2', '#80deea', '#4dd0e1', '#26c6da', '#00bcd4', '#00acc1', '#0097a7', '#00838f', '#006064', '#84ffff', '#18ffff', '#00e5ff', '#00b8d4']
    teal: ['#e0f2f1', '#b2dfdb', '#80cbc4', '#4db6ac', '#26a69a', '#009688', '#00897b', '#00796b', '#00695c', '#004d40', '#a7ffeb', '#64ffda', '#1de9b6', '#00bfa5']
    green: ['#e8f5e9', '#c8e6c9', '#a5d6a7', '#81c784', '#66bb6a', '#4caf50', '#43a047', '#388e3c', '#2e7d32', '#1b5e20', '#b9f6ca', '#69f0ae', '#00e676', '#00c853']
    lightgreen: ['#f1f8e9', '#dcedc8', '#c5e1a5', '#aed581', '#9ccc65', '#8bc34a', '#7cb342', '#689f38', '#558b2f', '#33691e', '#ccff90', '#b2ff59', '#76ff03', '#64dd17']
    lime: ['#f9fbe7', '#f0f4c3', '#e6ee9c', '#dce775', '#d4e157', '#cddc39', '#c0ca33', '#afb42b', '#9e9d24', '#827717', '#f4ff81', '#eeff41', '#c6ff00', '#aeea00']
    yellow: ['#fffde7', '#fff9c4', '#fff59d', '#fff176', '#ffee58', '#ffeb3b', '#fdd835', '#fbc02d', '#f9a825', '#f57f17', '#ffff8d', '#ffff00', '#ffea00', '#ffd600']
    amber: ['#fff8e1', '#ffecb3', '#ffe082', '#ffd54f', '#ffca28', '#ffc107', '#ffb300', '#ffa000', '#ff8f00', '#ff6f00', '#ffe57f', '#ffd740', '#ffc400', '#ffab00']
    orange: ['#fff3e0', '#ffe0b2', '#ffcc80', '#ffb74d', '#ffa726', '#ff9800', '#fb8c00', '#f57c00', '#ef6c00', '#e65100', '#ffd180', '#ffab40', '#ff9100', '#ff6d00']
    deeporange: ['#fbe9e7', '#ffccbc', '#ffab91', '#ff8a65', '#ff7043', '#ff5722', '#f4511e', '#e64a19', '#d84315', '#bf360c', '#ff9e80', '#ff6e40', '#ff3d00', '#dd2c00']
    brown: ['#efebe9', '#d7ccc8', '#bcaaa4', '#a1887f', '#8d6e63', '#795548', '#6d4c41', '#5d4037', '#4e342e', '#3e2723']
    grey: ['#fafafa', '#f5f5f5', '#eeeeee', '#e0e0e0', '#bdbdbd', '#9e9e9e', '#757575', '#616161', '#424242', '#212121']
    bluegrey: ['#eceff1', '#cfd8dc', '#b0bec5', '#90a4ae', '#78909c', '#607d8b', '#546e7a', '#455a64', '#37474f', '#263238']
  }

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

    # attach a button to the right side by the main ui
    @button = document.createElement 'BUTTON'
    @button.classList.add 'btn', 'btn-primary', 'btn-sm', 'icon', 'icon-chevron-up'

    @palettes.material = @initMaterial().component
    @palettes.custom = @initCustom().component

    @component.appendChild @palettes.material
    @component.appendChild @palettes.custom

    @popUpPalette = @initPopupPalette()

  # create the material design Palette
  initMaterial: ->
    material = new InnerPanel 'ccp-panel-inner', 'material'

    # swatch material palette
    @swatches.materialPalette = [
      {color: 'Red', hex: '#F44336'}
      {color: 'Pink', hex: '#E91E63'}
      {color: 'Purple', hex: '#9C27B0'}
      {color: 'Deep-purple', hex: '#673AB7'}
      {color: 'Indigo', hex: '#3F51B5'}
      {color: 'Blue', hex: '#2196F3'}
      {color: 'Light-blue', hex: '#03A9F4'}
      {color: 'Cyan', hex: '#00BCD4'}
      {color: 'Teal', hex: '#009688'}
      {color: 'Green', hex: '#4CAF50'}
      {color: 'Light-green', hex: '#8BC34A'}
      {color: 'Lime', hex: '#CDDC39'}
      {color: 'Yellow', hex: '#FFEB3B'}
      {color: 'Amber', hex: '#FFC107'}
      {color: 'Orange', hex: '#FF9800'}
      {color: 'Deep-orange', hex: '#FF5722'}
      {color: 'Brown', hex: '#795548'}
      {color: 'Grey', hex: '#9E9E9E'}
      {color: 'Blue-grey', hex: '#607D8B'}
      {color: 'Black', hex: '#000'}
      {color: 'White', hex: '#fff'}]

    @swatches.material = []
    docfrag = document.createDocumentFragment()
    for n in [1..21]
      swatch = new Swatch 'square'
      swatch.component.setAttribute 'data-color', @swatches.materialPalette[n - 1].hex
      swatch.component.setAttribute 'data-name', @swatches.materialPalette[n - 1].color.toLowerCase()
      @swatches.material.push swatch.component
      docfrag.appendChild swatch.component
    material.component.appendChild docfrag
    material

  # create the empty custom Palette
  initCustom: ->
    custom = new InnerPanel 'ccp-panel-inner', 'custom'
    custom.addClass 'invisible'
    @customButton = document.createElement 'BUTTON'
    @customButton.classList.add 'btn', 'btn-success', 'btn-sm', 'icon', 'icon-plus'
    custom.component.appendChild @customButton
    custom

  # add swatch to custom palette
  addSwatch: (color) ->
    # refer tiny color
    color = TinyColor color
    # add a new swatch with new color
    swatch = new Swatch 'square'
    swatch.component.setAttribute 'style', 'background: ' + color.toRgbString()
    swatch.component.setAttribute 'data-color', color.toRgbString()
    @palettes.custom.appendChild swatch.component

  # TODO create the page's Palette
  # TODO create the project's Palette

  # create the page popup palette
  initPopupPalette: ->
    popUpPalette = @createComponent 'ccp-palette-popup'
    @panel1 = new InnerPanel 'ccp-panel'
    @panel2 = new InnerPanel 'ccp-panel'
    @panel3 = new InnerPanel 'ccp-panel'

    # hide popUpPalette
    popUpPalette.classList.add 'invisible'

    # name the palette for use later
    @panel2.addClass 'material'
    @panel3.addClass 'custom'

    # enable focus when open
    @setFocusable @panel2.component
    @setFocusable @panel3.component

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
    @panel1.component.appendChild h_panel1
    @panel1.component.appendChild @popUpPaletteButton
    @panel2.component.appendChild h_panel2
    @panel3.component.appendChild h_panel3

    # attach swatches
    for n in [1..5]
      swatch = new Swatch 'square'
      @deleteFocusable swatch.component
      @panel2.component.appendChild swatch.component
      swatch = new Swatch 'square'
      @deleteFocusable swatch.component
      @panel3.component.appendChild swatch.component

    # attach them to the popUpPalette
    popUpPalette.appendChild @panel1.component
    popUpPalette.appendChild @panel2.component
    popUpPalette.appendChild @panel3.component
    # HACK keyboard tab manually
    JSTabber = new JSTabber (
      [
        @popUpPaletteButton
        @panel2.component
        @panel3.component
      ]
    )
    popUpPalette
