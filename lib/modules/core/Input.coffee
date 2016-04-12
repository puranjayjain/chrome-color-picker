helper = require '../helper/helper.coffee'

module.exports =
class Input extends helper
  active: {}
  element = ['HEX']

  ###*
   * [constructor Input in atom]
   *
   * @method constructor
   *
   * @param  {[element]}    container   [the container element to attach to]
   *
   * @param  {[String]}     preference  [preferred active component]
   *
   * @return {[component]}  [description]
  ###
  constructor: (container, preference) ->
    # dynamically create all types of input combinations
    # Hex
    hex = @createInput element
    container.appendChild hex
    # Set the currently active input along with it's type

    @active.type = preference
    # TODO switch preference according to the element and remove the invisible class
    @active.component = hex
    @active.component.classList.remove 'invisible'

  ###*
   * [createInput creates an input element with text label below]
   *
   * @method createInput
   *
   * @param  {[Object]}   inputs [Object with display text to add below] e.g = ['R','G','B']
   *
   * @return {[panel]}    [returns the element to add to the main panel]
  ###
  createInput: (inputs) ->
    component = @createComponent 'ccp-input'
    button = document.createElement 'BUTTON'
    button.classList.add 'btn', 'btn-primary', 'btn-xs', 'icon', 'icon-code'
    for text in inputs
      inner = @createComponent 'ccp-input-inner'
      input = document.createElement 'atom-text-editor'
      input.setAttribute 'type', 'text'
      input.classList.add text
      input.setAttribute('mini', true)
      # innerEditor = input.getModel() to get inner text editor instance
      # innerEditor.getText and setText api to change the text
      div = document.createElement 'DIV'
      div.textContent = text
      inner.appendChild input
      inner.appendChild div
      component.appendChild inner
    component.classList.add 'invisible'
    component.appendChild button
    # set button to active button to access it from the outside
    @active.button = button
    component
