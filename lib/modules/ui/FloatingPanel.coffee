helper = require '../helper/helper'

module.exports =
class FloatingPanel extends helper
  ###*
  * [constructor FloatingPanel in atom]
  *
  * @method constructor
  *
  * @param  {[tag]}         name  [name of the element like x-foo]
  * @param  {[element]}    addTo [add to which dom element]
  *
  * @return {[type]}    [description]
  ###

  constructor: (name, addTo) ->
    # create a custom element for the floating panel
    @component = @createComponent name
    @component.classList.add 'invisible'
    @triangle = @createComponent 'ccp-triangle'
    @component.appendChild @triangle
    addTo.appendChild @component

  # place the dialog according to your need
  setPlace: (Cursor, EditorRoot, Editor, Match) ->
    # get all relevant elements
    bounds = Editor.getBoundingClientRect()
    compBounds = @component.getBoundingClientRect()
    tabs = document.querySelector('[is=atom-tabs]')
    # clean slate
    @component.classList.remove 'down'
    @triangle.removeAttribute 'style'
    top = Cursor.top - Editor.getScrollTop() + Cursor.height + tabs.clientHeight + 10
    # get the actual cursor's bounds and prefer the selection
    ActualCursor = EditorRoot.querySelector('.highlight.selection > .region')
    # if this is not found then the region must be present
    if not ActualCursor
      ActualCursor = EditorRoot.querySelector('.cursor:last-of-type').getBoundingClientRect()
      left = ActualCursor.left - (compBounds.width / 2)
    else
      ActualCursor = ActualCursor.getBoundingClientRect()
      left = ActualCursor.left - (ActualCursor.width / 2)
    # check if the dialog is out of the area in the x axis, if yes put it in and position the triangle accordingly
    if left < bounds.left
      @triangle.setAttribute 'style', "left: calc(50% - #{bounds.left - left + 4}px)"
      left = bounds.left
    if (left + compBounds.width) > bounds.right
      @triangle.setAttribute 'style', "left: initial;right: calc(50% - #{10 - (bounds.right - left)}px)"
      left -= (bounds.right - left)
    # check if it is going out from the bottom
    if (top + compBounds.height) > bounds.bottom
      bottom = document.body.getBoundingClientRect().height + Cursor.height + 20 - top
      @component.classList.add 'down'
      # set the bottom and left
      @component.setAttribute 'style', "bottom: #{bottom}px; left: #{left}px"
    else
      # set the top and left
      @component.setAttribute 'style', "top: #{top}px; left: #{left}px"


  # add element to the panel
  add: (element) ->
    @component.appendChild element.component

  # toggle the visibility state of the dialog
  toggle: ->
    @component.classList.toggle 'invisible'

  #destroy the element from the dom
  destroy: ->
    @component.parentNode.removeChild @component
