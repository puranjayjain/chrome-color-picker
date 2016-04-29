# HACK
# override the dom tabbing order
# and manually create a tabbing order to tab within a set of elements in the mentioned order
module.exports =
class JSTabber

  ###*
   * [pass the elements whose default tabbing behavior you want to override]
   * @param  {[type]} elements [description]
   * @return {[type]}          [description]
  ###
  constructor: (elements) ->
    for index, element of elements
      console.log index
      # add element event for keyboard behavior
      element.addEventListener 'keydown', (e) =>
        isNext = true
        if e.shiftKey
          isNext = false
        if @isTabKey e
          newElement = @moveTo index, elements, isNext
          console.log newElement
          # focus it to the new element
          newElement.focus()

  # detect tab key
  isTabKey: (e) ->
    e.key is 'Tab' or e.code is 'Tab' or e.keyCode is 9

  # move to next element
  moveTo: (index, elements, isNext = true) ->
    console.log index
    # move to next item in list
    if isNext
      # if the item is last item move to First item
      if _index is (elements.length - 1)
        index = 0
      else
        ++index
    # move to previous item in list
    else
      # if it is the first item move to last item
      if index is 0
        index = (elements.length - 1)
      else
        --index
    console.log index
    # return the relevant element
    elements[index]
