###!
# getSize v2.0.2
# measure size of elements
# MIT license
###

module.exports =
class GetSize
  # -------------------------- measurements -------------------------- //
  measurements = [
    'paddingLeft'
    'paddingRight'
    'paddingTop'
    'paddingBottom'
    'marginLeft'
    'marginRight'
    'marginTop'
    'marginBottom'
    'borderLeftWidth'
    'borderRightWidth'
    'borderTopWidth'
    'borderBottomWidth'
  ]
  measurementsLength = measurements.length
  # -------------------------- setup -------------------------- //
  isSetup = false
  isBoxSizeOuter = undefined

  # -------------------------- helpers -------------------------- //
  # get a number from a string, not a percentage

  getStyleSize = (value) ->
    num = parseFloat(value)
    # not a percent like '100%', and a number
    isValid = value.indexOf('%') is -1 and not isNaN(num)
    isValid and num

  getZeroSize = ->
    size =
      width: 0
      height: 0
      innerWidth: 0
      innerHeight: 0
      outerWidth: 0
      outerHeight: 0
    i = 0
    while i < measurementsLength
      measurement = measurements[i]
      size[measurement] = 0
      i++
    size

  # -------------------------- getStyle -------------------------- //

  ###*
  # getStyle, get style of element, check for Firefox bug
  # https://bugzilla.mozilla.org/show_bug.cgi?id=548397
  ###
  getStyle = (elem) ->
    getComputedStyle(elem)

  ###*
  # setup
  # check isBoxSizerOuter
  # do on first getSize() rather than on page load for Firefox bug
  ###
  setup = ->
    # setup once
    if isSetup
      return
    isSetup = true
    # -------------------------- box sizing -------------------------- //

    ###*
    # WebKit measures the outer-width on style.width on border-box elems
    # IE & Firefox<29 measures the inner-width
    ###

    div = document.createElement('div')
    div.style.width = '200px'
    div.style.padding = '1px 2px 3px 4px'
    div.style.borderStyle = 'solid'
    div.style.borderWidth = '1px 2px 3px 4px'
    div.style.boxSizing = 'border-box'
    body = document.body or document.documentElement
    body.appendChild div
    style = getStyle(div)
    isBoxSizeOuter = getStyleSize(style.width) is 200
    body.removeChild div
    return

  # -------------------------- getSize -------------------------- //

  getSize: (elem) ->
    setup()
    # use querySelector if elem is string
    if typeof elem is 'string'
      elem = document.querySelector(elem)
    # do not proceed on non-objects
    if not elem or typeof elem isnt 'object' or not elem.nodeType
      return
    style = getStyle(elem)
    # if hidden, everything is 0
    if style.display is 'none'
      return getZeroSize()
    size = {}
    size.width = elem.offsetWidth
    size.height = elem.offsetHeight
    isBorderBox = size.isBorderBox = style.boxSizing is 'border-box'
    # get all measurements
    i = 0
    while i < measurementsLength
      measurement = measurements[i]
      value = style[measurement]
      num = parseFloat(value)
      # any 'auto', 'medium' value will be 0
      size[measurement] = if not isNaN(num) then num else 0
      i++
    paddingWidth = size.paddingLeft + size.paddingRight
    paddingHeight = size.paddingTop + size.paddingBottom
    marginWidth = size.marginLeft + size.marginRight
    marginHeight = size.marginTop + size.marginBottom
    borderWidth = size.borderLeftWidth + size.borderRightWidth
    borderHeight = size.borderTopWidth + size.borderBottomWidth
    isBorderBoxSizeOuter = isBorderBox and isBoxSizeOuter
    # overwrite width and height if we can get it from style
    styleWidth = getStyleSize(style.width)
    if styleWidth isnt false
      size.width = styleWidth + (if isBorderBoxSizeOuter then 0 else paddingWidth + borderWidth)
    styleHeight = getStyleSize(style.height)
    if styleHeight isnt false
      size.height = styleHeight + (if isBorderBoxSizeOuter then 0 else paddingHeight + borderHeight)
    size.innerWidth = size.width - (paddingWidth + borderWidth)
    size.innerHeight = size.height - (paddingHeight + borderHeight)
    size.outerWidth = size.width + marginWidth
    size.outerHeight = size.height + marginHeight
    size
