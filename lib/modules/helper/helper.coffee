# all the helper functions and prototypes are bundled here
module.exports =
class Helper
  String::isRegistered = ->
    document.createElement(@).constructor isnt HTMLElement

  # create a new component
  createComponent: (name) ->
    # create a custom element for the inner panel if not already done
    if not name.isRegistered()
      document.registerElement name

    component = document.createElement name

  # add element to the panel
  add: (element) ->
    @component.appendChild element.component

  # delete the element from it's parentNode
  delete: (el) ->
    if el?
      el.parentNode.removeChild el
    else
      @component.parentNode.removeChild @component

  # add class to the panel
  addClass: (classes) ->
    @component.classList.add classes

  # remove class from the panel
  removeClass: (classes) ->
    @component.classList.remove classes

  # set focusable
  setFocusable: (el, value = 1) ->
    if el
      el.tabIndex = value
    else
      @component.tabIndex = value

  # remove focusable
  removeFocusable: (el) ->
    if el
      el.tabIndex = '-1'
    else
      @component.tabIndex = '-1'

  # delete focusable
  deleteFocusable: (el) ->
    if el
      el.removeAttribute 'tabindex'
    else
      @component.removeAttribute 'tabindex'
