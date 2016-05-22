'use babel'

import helper from '../helper/helper'
import TinyColor from '../helper/TinyColor'

export default class Input extends helper {
  active = {}
  color = null
  hex = null
  rgb = null
  hsl = null
  formats = ['hex', 'rgb', 'hsl']
  // if the value was set using setText api
  forced = true

  /**
   * [constructor Input in atom]
   *
   * @method constructor
   *
   * @param  {[element]}    container   [the container element to attach to]
   *
   * @return {[component]}  [description]
  */
  constructor(container) {
    let element = ['hex']
    // dynamically create all types of input combinations and append them
    // Hex
    this.hex = this.createInput('hex', element)
    container.appendChild(this.hex)
    // Rgb/a
    element = ['r', 'g', 'b', 'a']
    this.rgb = this.createInput('rgb', element)
    container.appendChild(this.rgb)
    // Hsl/a
    element = ['h', 's', 'l', 'a']
    this.hsl = this.createInput('hsl', element)
    container.appendChild(this.hsl)
    let innerButtons = this.createComponent('ccp-side-buttons')
    // add a button to go through the list
    this.button = document.createElement('BUTTON')
    this.button.classList.add('btn', 'btn-primary', 'btn-sm', 'icon', 'icon-code')
    this.setFocusable(this.button)
    // add a toggle button to open / close the palette
    this.toggle = document.createElement('BUTTON')
    this.toggle.classList.add('btn', 'btn-info', 'btn-sm', 'icon')
    this.setFocusable(this.toggle)
    // add icon according to the setting of the palette on open
    this.toggle.classList.add(atom.config.get('chrome-color-picker.General.paletteOpen') ? 'icon-fold' : 'icon-unfold')
    // finally append them to the element
    innerButtons.appendChild(this.button)
    innerButtons.appendChild(this.toggle)
    // append the inner to the main container
    container.appendChild(innerButtons)
    // add event listeners
    this.attachEventListeners()
  }

  /**
   * [createInput creates an input element with text label below]
   *
   * @method createInput
   *
   * @param  {[String]}   name   [class name of the container element]
   * @param  {[Object]}   inputs [Object with display text to add below] e.g = ['R','G','B']
   *
   * @return {[panel]}    [returns the element to add to the main panel]
  */
  createInput(name, inputs) {
    let component = this.createComponent('ccp-input')
    for (let i = 0; i < inputs.length; i++) {
      let text = inputs[i]
      let inner = this.createComponent('ccp-input-inner')
      let input = document.createElement('atom-text-editor')
      input.setAttribute('type', 'text')
      input.classList.add(text)
      input.setAttribute('mini', true)
      // set tab index so that the editor is focusable
      this.removeFocusable(input)
      // innerEditor = input.getModel() to get inner text editor instance
      // innerEditor.getText and setText api to change the text
      let div = document.createElement('DIV')
      // exception for hex color
      if (name === 'hex') {
        text += ' or Named'
      }
      div.textContent = text
      inner.appendChild(input)
      inner.appendChild(div)
      component.appendChild(inner)
      component.classList.add(name, 'invisible')
    }
    return component
  }

  // add event listenerss to buttons
  attachEventListeners() {
    return this.button.addEventListener('click', () => {
      // cycle between active component states
      this.next()
      return this.UpdateUI()
    })
  }

  /**
   * [UpdateUI update the active text element]
   *
   * @method UpdateUI
   *
  */
  UpdateUI() {
    // reflect that the text was set forcefully
    this.forced = true
    let format = this.active.type
    this.color = new TinyColor(this.color)
    let alpha = false
    let thisColor = null
    // fallback format to use when there is an alpha value
    let fallbackAlphaFormat = atom.config.get('chrome-color-picker.HexColors.fallbackAlphaFormat')
    // if the input format is hex but we have an alpha in the input, default to mr. muggles err rgb
    if (this.color.getAlpha() < 1) {
      alpha = true
      // trigger the fallback alpha format property on an alpha < 1
      if (format === 'hex') {
        format = fallbackAlphaFormat
        this.changeFormat(fallbackAlphaFormat)
      }
    }

    // do something according with the format
    // hex
    if (format === 'hex') {
      var input = this.hex.querySelector('atom-text-editor.hex')
      input.getModel().setText(this.color.toHexString())
    }

    // rgb
    if (format === 'rgb' || format === 'rgba') {
      thisColor = this.color.toRgb()
      var input = this.rgb.querySelector('atom-text-editor.r')
      input.getModel().setText(thisColor.r.toString())
      input = this.rgb.querySelector('atom-text-editor.g')
      input.getModel().setText(thisColor.g.toString())
      input = this.rgb.querySelector('atom-text-editor.b')
      input.getModel().setText(thisColor.b.toString())
    }

    // toHsl
    if (format === 'hsl' || format === 'hsla') {
      thisColor = this.color.toHsl()
      var input = this.hsl.querySelector('atom-text-editor.h')
      input.getModel().setText(Math.round(thisColor.h).toString())
      input = this.hsl.querySelector('atom-text-editor.s')
      input.getModel().setText(`${Math.round(thisColor.s * 100).toString()}%`)
      input = this.hsl.querySelector('atom-text-editor.l')
      input.getModel().setText(`${Math.round(thisColor.l * 100).toString()}%`)
    }

    // if the alpha channel is present
    if (alpha) {
      var input = this[format].querySelector('atom-text-editor.a')
      input.getModel().setText(thisColor.a.toString())
      input.parentNode.removeAttribute('style')
      return this.alpha = true
    } else if (format !== 'hex') {
      var input = this[format].querySelector('atom-text-editor.a')
      input.parentNode.setAttribute('style', 'display: none')
      return this.alpha = false
    }
  }

  // change the current format to the one given
  changeFormat(format) {
    // convert all formats to the ones without the alpha channel
    format = format.replace('a', '')
    // hide all inputs
    for (let i = 0; i < this.formats.length; i++) {
      let name = this.formats[i]
      this[name].classList.add('invisible')
      this.removeFocusable(this[name].querySelector('atom-text-editor'))
    }

    // set it active
    this.active.type = format
    this.active.component = this[format]
    // set active focusable to all inner inputs
    // converts NodeList to Array
    let editorNodes = this[format].querySelectorAll('atom-text-editor')
    // returns NodeList
    // https://developer.mozilla.org/en-US/docs/Web/API/NodeList
    let editors = Array.from(editorNodes)
    for (let j = 0; j < editors.length; j++) {
      let editor = editors[j]
      this.setFocusable(editor)
    }
    // show the format
    this.active.component.classList.remove('invisible')
    return this.forced = true
  }

  // sets the next component of the active array
  next() {
    let current = this.formats.indexOf(this.active.type)
    if (current === (this.formats.length - 1)) {
      current = 0
    } else {
      current++
    }

    return this.changeFormat(this.formats[current])
  }

  // return formated color in a string format
  getColor() {
    // copy values
    let color = this.color.toString(this.active.type)
    let hexFormat = atom.config.get('chrome-color-picker.HexColors.forceHexSize')
    let rgbFormat = atom.config.get('chrome-color-picker.RgbColors.preferredFormat')
    let hslFormat = atom.config.get('chrome-color-picker.HslColors.preferredFormat')
    let hex3 = this.color.toString('hex3')
    let colorName = this.color.toName()
    // if the color is rgb and needed to converted to a format
    if (this.active.type === 'rgb' && rgbFormat !== 'standard') {
      color = this.color.toString(rgbFormat)
    }
    // if the color is hsl and needed to converted to a format
    if (this.active.type === 'hsl' && hslFormat !== 'standard') {
      color = this.color.toString(hslFormat)
    }
    // if the color needs to be shortened and can be
    if (this.color.getAlpha() < 1 && atom.config.get('chrome-color-picker.General.autoShortColor')) {
      // remove spaces
      color = color.replace(RegExp(' ', 'g'), '')
      // 0% => 0
      color = color.replace('0%', '0')
      // 1.0 => 1
      color = color.replace('1.0', '1')
      // 0. => .
      color = color.replace('0.', '.')
    }
    // if uppercase color settings
    if (this.active.type === 'hex' && atom.config.get('chrome-color-picker.HexColors.uppercaseHex')) {
      color = color.toUpperCase()
    }
    // force hex format
    if (this.active.type === 'hex' && hexFormat) {
      let hexForceColor = this.color.toString(hexFormat)
      // if possible then do it
      if (hexForceColor) {
        color = hexForceColor
      }
    }
    // if shortened hex settings
    if (hex3 && atom.config.get('chrome-color-picker.HexColors.autoShortHex')) {
      color = hex3
    }
    // if color can be converted to a name and the user wants it then just do it
    if (colorName && atom.config.get('chrome-color-picker.General.autoColorNames')) {
      color = colorName
    }
    return color
  }
}
