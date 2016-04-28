###
  html2canvas 0.4.1 <http://html2canvas.hertzen.com>
  Copyright (c) 2013 Niklas von Hertzen

  Released under MIT License
###

((window, document) ->

  # global variables
  borderSide = undefined

  toPX = (element, attribute, value) ->
    rsLeft = element.runtimeStyle and element.runtimeStyle[attribute]
    left = undefined
    style = element.style
    # Check if we are not dealing with pixels, (Opera has issues with this)
    # Ported from jQuery css.js
    # From the awesome hack by Dean Edwards
    # http://erik.eae.net/archives/2007/07/27/18.54.15/#comment-102291
    # If we're not dealing with a regular pixel number
    # but a number that has a weird ending, we need to convert it to pixels
    if not /^-?[0-9]+\.?[0-9]*(?:px)?$/i.test(value) and /^-?\d/.test(value)
      # Remember the original values
      left = style.left
      # Put in the new values to get a computed value out
      if rsLeft
        element.runtimeStyle.left = element.currentStyle.left
      style.left = if attribute is 'fontSize' then '1em' else value or 0
      value = style.pixelLeft + 'px'
      # Revert the changed values
      style.left = left
      if rsLeft
        element.runtimeStyle.left = rsLeft
    if not /^(thin|medium|thick)$/i.test(value)
      return Math.round(parseFloat(value)) + 'px'
    value

  asInt = (val) ->
    parseInt val, 10

  parseBackgroundSizePosition = (value, element, attribute, index) ->
    value = (value or '').split(',')
    value = value[index or 0] or value[0] or 'auto'
    value = _html2canvas.Util.trimText(value).split(' ')
    if attribute is 'backgroundSize' and (not value[0] or value[0].match(/cover|contain|auto/))
      #these values will be handled in the parent function
    else
      value[0] = if value[0].indexOf('%') is -1 then toPX(element, attribute + 'X', value[0]) else value[0]
      if value[1] is undefined
        if attribute is 'backgroundSize'
          value[1] = 'auto'
          return value
        else
          # IE 9 doesn't return double digit always
          value[1] = value[0]
      value[1] = if value[1].indexOf('%') is -1 then toPX(element, attribute + 'Y', value[1]) else value[1]
    value

  backgroundBoundsFactory = (prop, el, bounds, image, imageIndex, backgroundSize) ->
    bgposition = _html2canvas.Util.getCSS(el, prop, imageIndex)
    topPos = undefined
    left = undefined
    percentage = undefined
    val = undefined
    if bgposition.length is 1
      val = bgposition[0]
      bgposition = []
      bgposition[0] = val
      bgposition[1] = val
    if bgposition[0].toString().indexOf('%') isnt -1
      percentage = parseFloat(bgposition[0]) / 100
      left = bounds.width * percentage
      if prop isnt 'backgroundSize'
        left -= (backgroundSize or image).width * percentage
    else
      if prop is 'backgroundSize'
        if bgposition[0] is 'auto'
          left = image.width
        else
          if /contain|cover/.test(bgposition[0])
            resized = _html2canvas.Util.resizeBounds(image.width, image.height, bounds.width, bounds.height, bgposition[0])
            left = resized.width
            topPos = resized.height
          else
            left = parseInt(bgposition[0], 10)
      else
        left = parseInt(bgposition[0], 10)
    if bgposition[1] is 'auto'
      topPos = left / image.width * image.height
    else if bgposition[1].toString().indexOf('%') isnt -1
      percentage = parseFloat(bgposition[1]) / 100
      topPos = bounds.height * percentage
      if prop isnt 'backgroundSize'
        topPos -= (backgroundSize or image).height * percentage
    else
      topPos = parseInt(bgposition[1], 10)
    [
      left
      topPos
    ]

  h2cRenderContext = (width, height) ->
    storage = []
    {
      storage: storage
      width: width
      height: height
      clip: ->
        storage.push
          type: 'function'
          name: 'clip'
          'arguments': arguments
        return
      translate: ->
        storage.push
          type: 'function'
          name: 'translate'
          'arguments': arguments
        return
      fill: ->
        storage.push
          type: 'function'
          name: 'fill'
          'arguments': arguments
        return
      save: ->
        storage.push
          type: 'function'
          name: 'save'
          'arguments': arguments
        return
      restore: ->
        storage.push
          type: 'function'
          name: 'restore'
          'arguments': arguments
        return
      fillRect: ->
        storage.push
          type: 'function'
          name: 'fillRect'
          'arguments': arguments
        return
      createPattern: ->
        storage.push
          type: 'function'
          name: 'createPattern'
          'arguments': arguments
        return
      drawShape: ->
        shape = []
        storage.push
          type: 'function'
          name: 'drawShape'
          'arguments': shape
        {
          moveTo: ->
            shape.push
              name: 'moveTo'
              'arguments': arguments
            return
          lineTo: ->
            shape.push
              name: 'lineTo'
              'arguments': arguments
            return
          arcTo: ->
            shape.push
              name: 'arcTo'
              'arguments': arguments
            return
          bezierCurveTo: ->
            shape.push
              name: 'bezierCurveTo'
              'arguments': arguments
            return
          quadraticCurveTo: ->
            shape.push
              name: 'quadraticCurveTo'
              'arguments': arguments
            return

        }
      drawImage: ->
        storage.push
          type: 'function'
          name: 'drawImage'
          'arguments': arguments
        return
      fillText: ->
        storage.push
          type: 'function'
          name: 'fillText'
          'arguments': arguments
        return
      setVariable: (variable, value) ->
        storage.push
          type: 'variable'
          name: variable
          'arguments': value
        value

    }

  h2czContext = (zindex) ->
    {
      zindex: zindex
      children: []
    }

  'use strict'
  _html2canvas = {}
  previousElement = undefined
  computedCSS = undefined
  html2canvas = undefined
  _html2canvas.Util = {}

  _html2canvas.Util.log = (a) ->
    if _html2canvas.logging and window.console and window.console.log
      window.console.log a
    return

  _html2canvas.Util.trimText = ((isNative) ->
    (input) ->
      if isNative then isNative.apply(input) else ((input or '') + '').replace(/^\s+|\s+$/g, '')
  )(String::trim)

  _html2canvas.Util.asFloat = (v) ->
    parseFloat v

  do ->
    # TODO: support all possible length values
    TEXT_SHADOW_PROPERTY = /((rgba|rgb)\([^\)]+\)(\s-?\d+px){0,})/g
    TEXT_SHADOW_VALUES = /(-?\d+px)|(#.+)|(rgb\(.+\))|(rgba\(.+\))/g

    _html2canvas.Util.parseTextShadows = (value) ->
      if not value or value is 'none'
        return []
      # find multiple shadow declarations
      shadows = value.match(TEXT_SHADOW_PROPERTY)
      results = []
      i = 0
      while shadows and i < shadows.length
        s = shadows[i].match(TEXT_SHADOW_VALUES)
        results.push
          color: s[0]
          offsetX: if s[1] then s[1].replace('px', '') else 0
          offsetY: if s[2] then s[2].replace('px', '') else 0
          blur: if s[3] then s[3].replace('px', '') else 0
        i++
      results

    return

  _html2canvas.Util.parseBackgroundImage = (value) ->
    whitespace = ' \u000d\n\u0009'
    method = undefined
    definition = undefined
    prefix = undefined
    prefix_i = undefined
    block = undefined
    results = []
    c = undefined
    mode = 0
    numParen = 0
    quote = undefined
    args = undefined

    appendResult = ->
      if method
        if definition.substr(0, 1) is '"'
          definition = definition.substr(1, definition.length - 2)
        if definition
          args.push definition
        if method.substr(0, 1) is '-' and (prefix_i = method.indexOf('-', 1) + 1) > 0
          prefix = method.substr(0, prefix_i)
          method = method.substr(prefix_i)
        results.push
          prefix: prefix
          method: method.toLowerCase()
          value: block
          args: args
      args = []
      #for some odd reason, setting .length = 0 didn't work in safari
      method = prefix = definition = block = ''
      return

    appendResult()
    i = 0
    ii = value.length
    while i < ii
      c = value[i]
      if mode is 0 and whitespace.indexOf(c) > -1
        i++
        continue
      switch c
        when '"'
          if not quote
            quote = c
          else if quote is c
            quote = null
        when '('
          if quote
            break
          else if mode is 0
            mode = 1
            block += c
            i++
            continue
          else
            numParen++
        when ')'
          if quote
            break
          else if mode is 1
            if numParen is 0
              mode = 0
              block += c
              appendResult()
              i++
              continue
            else
              numParen--
        when ','
          if quote
            break
          else if mode is 0
            appendResult()
            i++
            continue
          else if mode is 1
            if numParen is 0 and not method.match(/^url$/i)
              args.push definition
              definition = ''
              block += c
              i++
              continue
      block += c
      if mode is 0
        method += c
      else
        definition += c
      i++
    appendResult()
    results

  _html2canvas.Util.Bounds = (element) ->
    clientRect = undefined
    bounds = {}
    if element.getBoundingClientRect
      clientRect = element.getBoundingClientRect()
      # TODO add scroll position to bounds, so no scrolling of window necessary
      bounds.top = clientRect.top
      bounds.bottom = clientRect.bottom or clientRect.top + clientRect.height
      bounds.left = clientRect.left
      bounds.width = element.offsetWidth
      bounds.height = element.offsetHeight
    bounds

  # TODO ideally, we'd want everything to go through this function instead of Util.Bounds,
  # but would require further work to calculate the correct positions for elements with offsetParents

  _html2canvas.Util.OffsetBounds = (element) ->
    parent = if element.offsetParent then _html2canvas.Util.OffsetBounds(element.offsetParent) else
      top: 0
      left: 0
    {
      top: element.offsetTop + parent.top
      bottom: element.offsetTop + element.offsetHeight + parent.top
      left: element.offsetLeft + parent.left
      width: element.offsetWidth
      height: element.offsetHeight
    }

  _html2canvas.Util.getCSS = (element, attribute, index) ->
    if previousElement isnt element
      computedCSS = document.defaultView.getComputedStyle(element, null)
    value = computedCSS[attribute]
    if /^background(Size|Position)$/.test(attribute)
      return parseBackgroundSizePosition(value, element, attribute, index)
    else if /border(Top|Bottom)(Left|Right)Radius/.test(attribute)
      arr = value.split(' ')
      if arr.length <= 1
        arr[1] = arr[0]
      return arr.map(asInt)
    value

  _html2canvas.Util.resizeBounds = (current_width, current_height, target_width, target_height, stretch_mode) ->
    target_ratio = target_width / target_height
    current_ratio = current_width / current_height
    output_width = undefined
    output_height = undefined
    if not stretch_mode or stretch_mode is 'auto'
      output_width = target_width
      output_height = target_height
    else if target_ratio < current_ratio ^ stretch_mode is 'contain'
      output_height = target_height
      output_width = target_height * current_ratio
    else
      output_width = target_width
      output_height = target_width / current_ratio
    {
      width: output_width
      height: output_height
    }

  _html2canvas.Util.BackgroundPosition = (el, bounds, image, imageIndex, backgroundSize) ->
    result = backgroundBoundsFactory('backgroundPosition', el, bounds, image, imageIndex, backgroundSize)
    {
      left: result[0]
      top: result[1]
    }

  _html2canvas.Util.BackgroundSize = (el, bounds, image, imageIndex) ->
    result = backgroundBoundsFactory('backgroundSize', el, bounds, image, imageIndex)
    {
      width: result[0]
      height: result[1]
    }

  _html2canvas.Util.Extend = (options, defaults) ->
    for key of options
      if options.hasOwnProperty(key)
        defaults[key] = options[key]
    defaults

  ###
  # Derived from jQuery.contents()
  # Copyright 2010, John Resig
  # Dual licensed under the MIT or GPL Version 2 licenses.
  # http://jquery.org/license
  ###

  _html2canvas.Util.Children = (elem) ->
    children = undefined
    try
      children = if elem.nodeName and elem.nodeName.toUpperCase() is 'IFRAME' then elem.contentDocument or elem.contentWindow.document else ((array) ->
        ret = []
        if array isnt null
          ((first, second) ->
            i = first.length
            j = 0
            if typeof second.length is 'number'
              l = second.length
              while j < l
                first[i++] = second[j]
                j++
            else
              while second[j] isnt undefined
                first[i++] = second[j++]
            first.length = i
            first
          ) ret, array
        ret
      )(elem.childNodes)
    catch ex
      _html2canvas.Util.log 'html2canvas.Util.Children failed with exception: ' + ex.message
      children = []
    children

  _html2canvas.Util.isTransparent = (backgroundColor) ->
    backgroundColor is 'transparent' or backgroundColor is 'rgba(0, 0, 0, 0)'

  _html2canvas.Util.Font = do ->
    fontData = {}
    (font, fontSize, doc) ->
      if fontData[font + '-' + fontSize] isnt undefined
        return fontData[font + '-' + fontSize]
      container = doc.createElement('div')
      img = doc.createElement('img')
      span = doc.createElement('span')
      sampleText = 'Hidden Text'
      baseline = undefined
      middle = undefined
      metricsObj = undefined
      container.style.visibility = 'hidden'
      container.style.fontFamily = font
      container.style.fontSize = fontSize
      container.style.margin = 0
      container.style.padding = 0
      doc.body.appendChild container
      # http://probablyprogramming.com/2009/03/15/the-tiniest-gif-ever (handtinywhite.gif)
      img.src = 'data:image/gif;base64,R0lGODlhAQABAIABAP///wAAACwAAAAAAQABAAACAkQBADs='
      img.width = 1
      img.height = 1
      img.style.margin = 0
      img.style.padding = 0
      img.style.verticalAlign = 'baseline'
      span.style.fontFamily = font
      span.style.fontSize = fontSize
      span.style.margin = 0
      span.style.padding = 0
      span.appendChild doc.createTextNode(sampleText)
      container.appendChild span
      container.appendChild img
      baseline = img.offsetTop - (span.offsetTop) + 1
      container.removeChild span
      container.appendChild doc.createTextNode(sampleText)
      container.style.lineHeight = 'normal'
      img.style.verticalAlign = 'super'
      middle = img.offsetTop - (container.offsetTop) + 1
      metricsObj =
        baseline: baseline
        lineWidth: 1
        middle: middle
      fontData[font + '-' + fontSize] = metricsObj
      doc.body.removeChild container
      metricsObj
  do ->
    Util = _html2canvas.Util
    Generate = {}

    addScrollStops = (grad) ->
      (colorStop) ->
        try
          grad.addColorStop colorStop.stop, colorStop.color
        catch e
          Util.log [
            'failed to add color stop: '
            e
            '; tried to add: '
            colorStop
          ]
        return

    _html2canvas.Generate = Generate
    reGradients = [
      /^(-webkit-linear-gradient)\(([a-z\s]+)([\w\d\.\s,%\(\)]+)\)$/
      /^(-o-linear-gradient)\(([a-z\s]+)([\w\d\.\s,%\(\)]+)\)$/
      /^(-webkit-gradient)\((linear|radial),\s((?:\d{1,3}%?)\s(?:\d{1,3}%?),\s(?:\d{1,3}%?)\s(?:\d{1,3}%?))([\w\d\.\s,%\(\)\-]+)\)$/
      /^(-moz-linear-gradient)\(((?:\d{1,3}%?)\s(?:\d{1,3}%?))([\w\d\.\s,%\(\)]+)\)$/
      /^(-webkit-radial-gradient)\(((?:\d{1,3}%?)\s(?:\d{1,3}%?)),\s(\w+)\s([a-z\-]+)([\w\d\.\s,%\(\)]+)\)$/
      /^(-moz-radial-gradient)\(((?:\d{1,3}%?)\s(?:\d{1,3}%?)),\s(\w+)\s?([a-z\-]*)([\w\d\.\s,%\(\)]+)\)$/
      /^(-o-radial-gradient)\(((?:\d{1,3}%?)\s(?:\d{1,3}%?)),\s(\w+)\s([a-z\-]+)([\w\d\.\s,%\(\)]+)\)$/
    ]

    ###
    # TODO: Add IE10 vendor prefix (-ms) support
    # TODO: Add W3C gradient (linear-gradient) support
    # TODO: Add old Webkit -webkit-gradient(radial, ...) support
    # TODO: Maybe some RegExp optimizations are possible ;o)
    ###

    Generate.parseGradient = (css, bounds) ->
      gradient = undefined
      i = undefined
      len = reGradients.length
      m1 = undefined
      stop = undefined
      m2 = undefined
      m2Len = undefined
      step = undefined
      m3 = undefined
      tl = undefined
      tr = undefined
      br = undefined
      bl = undefined
      i = 0
      while i < len
        m1 = css.match(reGradients[i])
        if m1
          break
        i += 1
      if m1
        switch m1[1]
          when '-webkit-linear-gradient', '-o-linear-gradient'
            gradient =
              type: 'linear'
              x0: null
              y0: null
              x1: null
              y1: null
              colorStops: []
            # get coordinates
            m2 = m1[2].match(/\w+/g)
            if m2
              m2Len = m2.length
              i = 0
              while i < m2Len
                switch m2[i]
                  when 'top'
                    gradient.y0 = 0
                    gradient.y1 = bounds.height
                  when 'right'
                    gradient.x0 = bounds.width
                    gradient.x1 = 0
                  when 'bottom'
                    gradient.y0 = bounds.height
                    gradient.y1 = 0
                  when 'left'
                    gradient.x0 = 0
                    gradient.x1 = bounds.width
                i += 1
            if gradient.x0 is null and gradient.x1 is null
              # center
              gradient.x0 = gradient.x1 = bounds.width / 2
            if gradient.y0 is null and gradient.y1 is null
              # center
              gradient.y0 = gradient.y1 = bounds.height / 2
            # get colors and stops
            m2 = m1[3].match(/((?:rgb|rgba)\(\d{1,3},\s\d{1,3},\s\d{1,3}(?:,\s[0-9\.]+)?\)(?:\s\d{1,3}(?:%|px))?)+/g)
            if m2
              m2Len = m2.length
              step = 1 / Math.max(m2Len - 1, 1)
              i = 0
              while i < m2Len
                m3 = m2[i].match(/((?:rgb|rgba)\(\d{1,3},\s\d{1,3},\s\d{1,3}(?:,\s[0-9\.]+)?\))\s*(\d{1,3})?(%|px)?/)
                if m3[2]
                  stop = parseFloat(m3[2])
                  if m3[3] is '%'
                    stop /= 100
                  else
                    # px - stupid opera
                    stop /= bounds.width
                else
                  stop = i * step
                gradient.colorStops.push
                  color: m3[1]
                  stop: stop
                i += 1
          when '-webkit-gradient'
            gradient =
              type: if m1[2] is 'radial' then 'circle' else m1[2]
              x0: 0
              y0: 0
              x1: 0
              y1: 0
              colorStops: []
            # get coordinates
            m2 = m1[3].match(/(\d{1,3})%?\s(\d{1,3})%?,\s(\d{1,3})%?\s(\d{1,3})%?/)
            if m2
              gradient.x0 = m2[1] * bounds.width / 100
              gradient.y0 = m2[2] * bounds.height / 100
              gradient.x1 = m2[3] * bounds.width / 100
              gradient.y1 = m2[4] * bounds.height / 100
            # get colors and stops
            m2 = m1[4].match(/((?:from|to|color-stop)\((?:[0-9\.]+,\s)?(?:rgb|rgba)\(\d{1,3},\s\d{1,3},\s\d{1,3}(?:,\s[0-9\.]+)?\)\))+/g)
            if m2
              m2Len = m2.length
              i = 0
              while i < m2Len
                m3 = m2[i].match(/(from|to|color-stop)\(([0-9\.]+)?(?:,\s)?((?:rgb|rgba)\(\d{1,3},\s\d{1,3},\s\d{1,3}(?:,\s[0-9\.]+)?\))\)/)
                stop = parseFloat(m3[2])
                if m3[1] is 'from'
                  stop = 0.0
                if m3[1] is 'to'
                  stop = 1.0
                gradient.colorStops.push
                  color: m3[3]
                  stop: stop
                i += 1
          when '-moz-linear-gradient'
            gradient =
              type: 'linear'
              x0: 0
              y0: 0
              x1: 0
              y1: 0
              colorStops: []
            # get coordinates
            m2 = m1[2].match(/(\d{1,3})%?\s(\d{1,3})%?/)
            # m2[1] is 0%   -> left
            # m2[1] is 50%  -> center
            # m2[1] is 100% -> right
            # m2[2] is 0%   -> top
            # m2[2] is 50%  -> center
            # m2[2] is 100% -> bottom
            if m2
              gradient.x0 = m2[1] * bounds.width / 100
              gradient.y0 = m2[2] * bounds.height / 100
              gradient.x1 = bounds.width - (gradient.x0)
              gradient.y1 = bounds.height - (gradient.y0)
            # get colors and stops
            m2 = m1[3].match(/((?:rgb|rgba)\(\d{1,3},\s\d{1,3},\s\d{1,3}(?:,\s[0-9\.]+)?\)(?:\s\d{1,3}%)?)+/g)
            if m2
              m2Len = m2.length
              step = 1 / Math.max(m2Len - 1, 1)
              i = 0
              while i < m2Len
                m3 = m2[i].match(/((?:rgb|rgba)\(\d{1,3},\s\d{1,3},\s\d{1,3}(?:,\s[0-9\.]+)?\))\s*(\d{1,3})?(%)?/)
                if m3[2]
                  stop = parseFloat(m3[2])
                  if m3[3]
                    # percentage
                    stop /= 100
                else
                  stop = i * step
                gradient.colorStops.push
                  color: m3[1]
                  stop: stop
                i += 1
          when '-webkit-radial-gradient', '-moz-radial-gradient', '-o-radial-gradient'
            gradient =
              type: 'circle'
              x0: 0
              y0: 0
              x1: bounds.width
              y1: bounds.height
              cx: 0
              cy: 0
              rx: 0
              ry: 0
              colorStops: []
            # center
            m2 = m1[2].match(/(\d{1,3})%?\s(\d{1,3})%?/)
            if m2
              gradient.cx = m2[1] * bounds.width / 100
              gradient.cy = m2[2] * bounds.height / 100
            # size
            m2 = m1[3].match(/\w+/)
            m3 = m1[4].match(/[a-z\-]*/)
            if m2 and m3
              switch m3[0]
                # is equivalent to farthest-corner
                when 'farthest-corner', 'cover', ''
                  # mozilla removes "cover" from definition :(
                  tl = Math.sqrt(gradient.cx ** 2 + gradient.cy ** 2)
                  tr = Math.sqrt(gradient.cx ** 2 + (gradient.y1 - (gradient.cy)) ** 2)
                  br = Math.sqrt((gradient.x1 - (gradient.cx)) ** 2 + (gradient.y1 - (gradient.cy)) ** 2)
                  bl = Math.sqrt((gradient.x1 - (gradient.cx)) ** 2 + gradient.cy ** 2)
                  gradient.rx = gradient.ry = Math.max(tl, tr, br, bl)
                when 'closest-corner'
                  tl = Math.sqrt(gradient.cx ** 2 + gradient.cy ** 2)
                  tr = Math.sqrt(gradient.cx ** 2 + (gradient.y1 - (gradient.cy)) ** 2)
                  br = Math.sqrt((gradient.x1 - (gradient.cx)) ** 2 + (gradient.y1 - (gradient.cy)) ** 2)
                  bl = Math.sqrt((gradient.x1 - (gradient.cx)) ** 2 + gradient.cy ** 2)
                  gradient.rx = gradient.ry = Math.min(tl, tr, br, bl)
                when 'farthest-side'
                  if m2[0] is 'circle'
                    gradient.rx = gradient.ry = Math.max(gradient.cx, gradient.cy, gradient.x1 - (gradient.cx), gradient.y1 - (gradient.cy))
                  else
                    # ellipse
                    gradient.type = m2[0]
                    gradient.rx = Math.max(gradient.cx, gradient.x1 - (gradient.cx))
                    gradient.ry = Math.max(gradient.cy, gradient.y1 - (gradient.cy))
                when 'closest-side', 'contain'
                  # is equivalent to closest-side
                  if m2[0] is 'circle'
                    gradient.rx = gradient.ry = Math.min(gradient.cx, gradient.cy, gradient.x1 - (gradient.cx), gradient.y1 - (gradient.cy))
                  else
                    # ellipse
                    gradient.type = m2[0]
                    gradient.rx = Math.min(gradient.cx, gradient.x1 - (gradient.cx))
                    gradient.ry = Math.min(gradient.cy, gradient.y1 - (gradient.cy))
                # TODO: add support for "30px 40px" sizes (webkit only)
            # color stops
            m2 = m1[5].match(/((?:rgb|rgba)\(\d{1,3},\s\d{1,3},\s\d{1,3}(?:,\s[0-9\.]+)?\)(?:\s\d{1,3}(?:%|px))?)+/g)
            if m2
              m2Len = m2.length
              step = 1 / Math.max(m2Len - 1, 1)
              i = 0
              while i < m2Len
                m3 = m2[i].match(/((?:rgb|rgba)\(\d{1,3},\s\d{1,3},\s\d{1,3}(?:,\s[0-9\.]+)?\))\s*(\d{1,3})?(%|px)?/)
                if m3[2]
                  stop = parseFloat(m3[2])
                  if m3[3] is '%'
                    stop /= 100
                  else
                    # px - stupid opera
                    stop /= bounds.width
                else
                  stop = i * step
                gradient.colorStops.push
                  color: m3[1]
                  stop: stop
                i += 1
      gradient

    Generate.Gradient = (src, bounds) ->
      if bounds.width is 0 or bounds.height is 0
        return
      canvas = document.createElement('canvas')
      ctx = canvas.getContext('2d')
      gradient = undefined
      grad = undefined
      canvas.width = bounds.width
      canvas.height = bounds.height
      # TODO: add support for multi defined background gradients
      gradient = _html2canvas.Generate.parseGradient(src, bounds)
      if gradient
        switch gradient.type
          when 'linear'
            grad = ctx.createLinearGradient(gradient.x0, gradient.y0, gradient.x1, gradient.y1)
            gradient.colorStops.forEach addScrollStops(grad)
            ctx.fillStyle = grad
            ctx.fillRect 0, 0, bounds.width, bounds.height
          when 'circle'
            grad = ctx.createRadialGradient(gradient.cx, gradient.cy, 0, gradient.cx, gradient.cy, gradient.rx)
            gradient.colorStops.forEach addScrollStops(grad)
            ctx.fillStyle = grad
            ctx.fillRect 0, 0, bounds.width, bounds.height
          when 'ellipse'
            canvasRadial = document.createElement('canvas')
            ctxRadial = canvasRadial.getContext('2d')
            ri = Math.max(gradient.rx, gradient.ry)
            di = ri * 2
            canvasRadial.width = canvasRadial.height = di
            grad = ctxRadial.createRadialGradient(gradient.rx, gradient.ry, 0, gradient.rx, gradient.ry, ri)
            gradient.colorStops.forEach addScrollStops(grad)
            ctxRadial.fillStyle = grad
            ctxRadial.fillRect 0, 0, di, di
            ctx.fillStyle = gradient.colorStops[gradient.colorStops.length - 1].color
            ctx.fillRect 0, 0, canvas.width, canvas.height
            ctx.drawImage canvasRadial, gradient.cx - (gradient.rx), gradient.cy - (gradient.ry), 2 * gradient.rx, 2 * gradient.ry
      canvas

    Generate.ListAlpha = (number) ->
      tmp = ''
      modulus = undefined
      loop
        modulus = number % 26
        tmp = String.fromCharCode(modulus + 64) + tmp
        number = number / 26
        unless number * 26 > 26
          break
      tmp

    Generate.ListRoman = (number) ->
      romanArray = [
        'M'
        'CM'
        'D'
        'CD'
        'C'
        'XC'
        'L'
        'XL'
        'X'
        'IX'
        'V'
        'IV'
        'I'
      ]
      decimal = [
        1000
        900
        500
        400
        100
        90
        50
        40
        10
        9
        5
        4
        1
      ]
      roman = ''
      v = undefined
      len = romanArray.length
      if number <= 0 or number >= 4000
        return number
      v = 0
      while v < len
        while number >= decimal[v]
          number -= decimal[v]
          roman += romanArray[v]
        v += 1
      roman

    return

  _html2canvas.Parse = (images, options) ->

    documentWidth = ->
      Math.max Math.max(doc.body.scrollWidth, doc.documentElement.scrollWidth), Math.max(doc.body.offsetWidth, doc.documentElement.offsetWidth), Math.max(doc.body.clientWidth, doc.documentElement.clientWidth)

    documentHeight = ->
      Math.max Math.max(doc.body.scrollHeight, doc.documentElement.scrollHeight), Math.max(doc.body.offsetHeight, doc.documentElement.offsetHeight), Math.max(doc.body.clientHeight, doc.documentElement.clientHeight)

    getCSSInt = (element, attribute) ->
      val = parseInt(getCSS(element, attribute), 10)
      if isNaN(val) then 0 else val
      # borders in old IE are throwing 'medium' for demo.html

    renderRect = (ctx, x, y, w, h, bgcolor) ->
      if bgcolor isnt 'transparent'
        ctx.setVariable 'fillStyle', bgcolor
        ctx.fillRect x, y, w, h
        numDraws += 1
      return

    capitalize = (m, p1, p2) ->
      if m.length > 0
        return p1 + p2.toUpperCase()
      return

    textTransform = (text, transform) ->
      switch transform
        when 'lowercase'
          return text.toLowerCase()
        when 'capitalize'
          return text.replace(/(^|\s|:|-|\(|\))([a-z])/g, capitalize)
        when 'uppercase'
          return text.toUpperCase()
        else
          return text
      return

    noLetterSpacing = (letter_spacing) ->
      /^(normal|none|0px)$/.test letter_spacing

    drawText = (currentText, x, y, ctx) ->
      if currentText isnt null and Util.trimText(currentText).length > 0
        ctx.fillText currentText, x, y
        numDraws += 1
      return

    setTextVariables = (ctx, el, text_decoration, color) ->
      align = false
      bold = getCSS(el, 'fontWeight')
      family = getCSS(el, 'fontFamily')
      size = getCSS(el, 'fontSize')
      shadows = Util.parseTextShadows(getCSS(el, 'textShadow'))
      switch parseInt(bold, 10)
        when 401
          bold = 'bold'
        when 400
          bold = 'normal'
      ctx.setVariable 'fillStyle', color
      ctx.setVariable 'font', [
        getCSS(el, 'fontStyle')
        getCSS(el, 'fontVariant')
        bold
        size
        family
      ].join(' ')
      ctx.setVariable 'textAlign', if align then 'right' else 'left'
      if shadows.length
        # TODO: support multiple text shadows
        # apply the first text shadow
        ctx.setVariable 'shadowColor', shadows[0].color
        ctx.setVariable 'shadowOffsetX', shadows[0].offsetX
        ctx.setVariable 'shadowOffsetY', shadows[0].offsetY
        ctx.setVariable 'shadowBlur', shadows[0].blur
      if text_decoration isnt 'none'
        return Util.Font(family, size, doc)
      return

    renderTextDecoration = (ctx, text_decoration, bounds, metrics, color) ->
      switch text_decoration
        when 'underline'
          # Draws a line at the baseline of the font
          # TODO As some browsers display the line as more than 1px if the font-size is big, need to take that into account both in position and size
          renderRect ctx, bounds.left, Math.round(bounds.top + metrics.baseline + metrics.lineWidth), bounds.width, 1, color
        when 'overline'
          renderRect ctx, bounds.left, Math.round(bounds.top), bounds.width, 1, color
        when 'line-through'
          # TODO try and find exact position for line-through
          renderRect ctx, bounds.left, Math.ceil(bounds.top + metrics.middle + metrics.lineWidth), bounds.width, 1, color
      return

    getTextBounds = (state, text, textDecoration, isLast, transform) ->
      bounds = undefined
      if support.rangeBounds and not transform
        if textDecoration isnt 'none' or Util.trimText(text).length isnt 0
          bounds = textRangeBounds(text, state.node, state.textOffset)
        state.textOffset += text.length
      else if state.node and typeof state.node.nodeValue is 'string'
        newTextNode = if isLast then state.node.splitText(text.length) else null
        bounds = textWrapperBounds(state.node, transform)
        state.node = newTextNode
      bounds

    textRangeBounds = (text, textNode, textOffset) ->
      range = doc.createRange()
      range.setStart textNode, textOffset
      range.setEnd textNode, textOffset + text.length
      range.getBoundingClientRect()

    textWrapperBounds = (oldTextNode, transform) ->
      parent = oldTextNode.parentNode
      wrapElement = doc.createElement('wrapper')
      backupText = oldTextNode.cloneNode(true)
      wrapElement.appendChild oldTextNode.cloneNode(true)
      parent.replaceChild wrapElement, oldTextNode
      bounds = if transform then Util.OffsetBounds(wrapElement) else Util.Bounds(wrapElement)
      parent.replaceChild backupText, wrapElement
      bounds

    renderText = (el, textNode, stack) ->
      ctx = stack.ctx
      color = getCSS(el, 'color')
      textDecoration = getCSS(el, 'textDecoration')
      textAlign = getCSS(el, 'textAlign')
      metrics = undefined
      textList = undefined
      state =
        node: textNode
        textOffset: 0
      if Util.trimText(textNode.nodeValue).length > 0
        textNode.nodeValue = textTransform(textNode.nodeValue, getCSS(el, 'textTransform'))
        textAlign = textAlign.replace([ '-webkit-auto' ], [ 'auto' ])
        textList = if not options.letterRendering and /^(left|right|justify|auto)$/.test(textAlign) and noLetterSpacing(getCSS(el, 'letterSpacing')) then textNode.nodeValue.split(/(\b| )/) else textNode.nodeValue.split('')
        metrics = setTextVariables(ctx, el, textDecoration, color)
        if options.chinese
          textList.forEach (word, index) ->
            if /.*[\u4E00-\u9FA5].*$/.test(word)
              word = word.split('')
              word.unshift index, 1
              textList.splice.apply textList, word
            return
        textList.forEach (text, index) ->
          bounds = getTextBounds(state, text, textDecoration, index < textList.length - 1, stack.transform.matrix)
          if bounds
            drawText text, bounds.left, bounds.bottom, ctx
            renderTextDecoration ctx, textDecoration, bounds, metrics, color
          return
      return

    listPosition = (element, val) ->
      boundElement = doc.createElement('boundelement')
      originalType = undefined
      bounds = undefined
      boundElement.style.display = 'inline'
      originalType = element.style.listStyleType
      element.style.listStyleType = 'none'
      boundElement.appendChild doc.createTextNode(val)
      element.insertBefore boundElement, element.firstChild
      bounds = Util.Bounds(boundElement)
      element.removeChild boundElement
      element.style.listStyleType = originalType
      bounds

    elementIndex = (el) ->
      i = -1
      count = 1
      childs = el.parentNode.childNodes
      if el.parentNode
        while childs[++i] isnt el
          if childs[i].nodeType is 1
            count++
        count
      else
        -1

    listItemText = (element, type) ->
      currentIndex = elementIndex(element)
      text = undefined
      switch type
        when 'decimal'
          text = currentIndex
        when 'decimal-leading-zero'
          text = if currentIndex.toString().length is 1 then (currentIndex = '0' + currentIndex.toString()) else currentIndex.toString()
        when 'upper-roman'
          text = _html2canvas.Generate.ListRoman(currentIndex)
        when 'lower-roman'
          text = _html2canvas.Generate.ListRoman(currentIndex).toLowerCase()
        when 'lower-alpha'
          text = _html2canvas.Generate.ListAlpha(currentIndex).toLowerCase()
        when 'upper-alpha'
          text = _html2canvas.Generate.ListAlpha(currentIndex)
      text + '. '

    renderListItem = (element, stack, elBounds) ->
      x = undefined
      text = undefined
      ctx = stack.ctx
      type = getCSS(element, 'listStyleType')
      listBounds = undefined
      if /^(decimal|decimal-leading-zero|upper-alpha|upper-latin|upper-roman|lower-alpha|lower-greek|lower-latin|lower-roman)$/i.test(type)
        text = listItemText(element, type)
        listBounds = listPosition(element, text)
        setTextVariables ctx, element, 'none', getCSS(element, 'color')
        if getCSS(element, 'listStylePosition') is 'inside'
          ctx.setVariable 'textAlign', 'left'
          x = elBounds.left
        else
          return
        drawText text, x, listBounds.bottom, ctx
      return

    loadImage = (src) ->
      img = images[src]
      if img and img.succeeded is true then img.img else false

    clipBounds = (src, dst) ->
      x = Math.max(src.left, dst.left)
      y = Math.max(src.top, dst.top)
      x2 = Math.min(src.left + src.width, dst.left + dst.width)
      y2 = Math.min(src.top + src.height, dst.top + dst.height)
      {
        left: x
        top: y
        width: x2 - x
        height: y2 - y
      }

    setZ = (element, stack, parentStack) ->
      newContext = undefined
      isPositioned = stack.cssPosition isnt 'static'
      zIndex = if isPositioned then getCSS(element, 'zIndex') else 'auto'
      opacity = getCSS(element, 'opacity')
      isFloated = getCSS(element, 'cssFloat') isnt 'none'
      # https://developer.mozilla.org/en-US/docs/Web/Guide/CSS/Understanding_z_index/The_stacking_context
      # When a new stacking context should be created:
      # the root element (HTML),
      # positioned (absolutely or relatively) with a z-index value other than "auto",
      # elements with an opacity value less than 1. (See the specification for opacity),
      # on mobile WebKit and Chrome 22+, position: fixed always creates a new stacking context, even when z-index is "auto" (See this post)
      stack.zIndex = newContext = h2czContext(zIndex)
      newContext.isPositioned = isPositioned
      newContext.isFloated = isFloated
      newContext.opacity = opacity
      newContext.ownStacking = zIndex isnt 'auto' or opacity < 1
      if parentStack
        parentStack.zIndex.children.push stack
      return

    renderImage = (ctx, element, image, bounds, borders) ->
      paddingLeft = getCSSInt(element, 'paddingLeft')
      paddingTop = getCSSInt(element, 'paddingTop')
      paddingRight = getCSSInt(element, 'paddingRight')
      paddingBottom = getCSSInt(element, 'paddingBottom')
      bLeft = bounds.left + paddingLeft + borders[3].width
      bTop = bounds.top + paddingTop + borders[0].width
      bWidth = bounds.width - (borders[1].width + borders[3].width + paddingLeft + paddingRight)
      drawImage ctx, image, 0, 0, image.width, image.height, bLeft, bTop, bWidth, bounds.height - (borders[0].width + borders[2].width + paddingTop + paddingBottom)
      return

    getBorderData = (element) ->
      [
        'Top'
        'Right'
        'Bottom'
        'Left'
      ].map (side) ->
        {
          width: getCSSInt(element, 'border' + side + 'Width')
          color: getCSS(element, 'border' + side + 'Color')
        }

    getBorderRadiusData = (element) ->
      [
        'TopLeft'
        'TopRight'
        'BottomRight'
        'BottomLeft'
      ].map (side) ->
        getCSS element, 'border' + side + 'Radius'

    bezierCurve = (start, startControl, endControl, end) ->

      lerp = (a, b, t) ->
        {
          x: a.x + (b.x - (a.x)) * t
          y: a.y + (b.y - (a.y)) * t
        }

      {
        start: start
        startControl: startControl
        endControl: endControl
        end: end
        subdivide: (t) ->
          ab = lerp(start, startControl, t)
          bc = lerp(startControl, endControl, t)
          cd = lerp(endControl, end, t)
          abbc = lerp(ab, bc, t)
          bccd = lerp(bc, cd, t)
          dest = lerp(abbc, bccd, t)
          [
            bezierCurve(start, ab, abbc, dest)
            bezierCurve(dest, bccd, cd, end)
          ]
        curveTo: (borderArgs) ->
          borderArgs.push [
            'bezierCurve'
            startControl.x
            startControl.y
            endControl.x
            endControl.y
            end.x
            end.y
          ]
          return
        curveToReversed: (borderArgs) ->
          borderArgs.push [
            'bezierCurve'
            endControl.x
            endControl.y
            startControl.x
            startControl.y
            start.x
            start.y
          ]
          return

      }

    parseCorner = (borderArgs, radius1, radius2, corner1, corner2, x, y) ->
      if radius1[0] > 0 or radius1[1] > 0
        borderArgs.push [
          'line'
          corner1[0].start.x
          corner1[0].start.y
        ]
        corner1[0].curveTo borderArgs
        corner1[1].curveTo borderArgs
      else
        borderArgs.push [
          'line'
          x
          y
        ]
      if radius2[0] > 0 or radius2[1] > 0
        borderArgs.push [
          'line'
          corner2[0].start.x
          corner2[0].start.y
        ]
      return

    drawSide = (borderData, radius1, radius2, outer1, inner1, outer2, inner2) ->
      borderArgs = []
      if radius1[0] > 0 or radius1[1] > 0
        borderArgs.push [
          'line'
          outer1[1].start.x
          outer1[1].start.y
        ]
        outer1[1].curveTo borderArgs
      else
        borderArgs.push [
          'line'
          borderData.c1[0]
          borderData.c1[1]
        ]
      if radius2[0] > 0 or radius2[1] > 0
        borderArgs.push [
          'line'
          outer2[0].start.x
          outer2[0].start.y
        ]
        outer2[0].curveTo borderArgs
        borderArgs.push [
          'line'
          inner2[0].end.x
          inner2[0].end.y
        ]
        inner2[0].curveToReversed borderArgs
      else
        borderArgs.push [
          'line'
          borderData.c2[0]
          borderData.c2[1]
        ]
        borderArgs.push [
          'line'
          borderData.c3[0]
          borderData.c3[1]
        ]
      if radius1[0] > 0 or radius1[1] > 0
        borderArgs.push [
          'line'
          inner1[1].end.x
          inner1[1].end.y
        ]
        inner1[1].curveToReversed borderArgs
      else
        borderArgs.push [
          'line'
          borderData.c4[0]
          borderData.c4[1]
        ]
      borderArgs

    calculateCurvePoints = (bounds, borderRadius, borders) ->
      x = bounds.left
      y = bounds.top
      width = bounds.width
      height = bounds.height
      tlh = borderRadius[0][0]
      tlv = borderRadius[0][1]
      trh = borderRadius[1][0]
      trv = borderRadius[1][1]
      brh = borderRadius[2][0]
      brv = borderRadius[2][1]
      blh = borderRadius[3][0]
      blv = borderRadius[3][1]
      topWidth = width - trh
      rightHeight = height - brv
      bottomWidth = width - brh
      leftHeight = height - blv
      {
        topLeftOuter: getCurvePoints(x, y, tlh, tlv).topLeft.subdivide(0.5)
        topLeftInner: getCurvePoints(x + borders[3].width, y + borders[0].width, Math.max(0, tlh - (borders[3].width)), Math.max(0, tlv - (borders[0].width))).topLeft.subdivide(0.5)
        topRightOuter: getCurvePoints(x + topWidth, y, trh, trv).topRight.subdivide(0.5)
        topRightInner: getCurvePoints(x + Math.min(topWidth, width + borders[3].width), y + borders[0].width, (if topWidth > width + borders[3].width then 0 else trh - (borders[3].width)), trv - (borders[0].width)).topRight.subdivide(0.5)
        bottomRightOuter: getCurvePoints(x + bottomWidth, y + rightHeight, brh, brv).bottomRight.subdivide(0.5)
        bottomRightInner: getCurvePoints(x + Math.min(bottomWidth, width + borders[3].width), y + Math.min(rightHeight, height + borders[0].width), Math.max(0, brh - (borders[1].width)), Math.max(0, brv - (borders[2].width))).bottomRight.subdivide(0.5)
        bottomLeftOuter: getCurvePoints(x, y + leftHeight, blh, blv).bottomLeft.subdivide(0.5)
        bottomLeftInner: getCurvePoints(x + borders[3].width, y + leftHeight, Math.max(0, blh - (borders[3].width)), Math.max(0, blv - (borders[2].width))).bottomLeft.subdivide(0.5)
      }

    getBorderClip = (element, borderPoints, borders, radius, bounds) ->
      backgroundClip = getCSS(element, 'backgroundClip')
      borderArgs = []
      switch backgroundClip
        when 'content-box', 'padding-box'
          parseCorner borderArgs, radius[0], radius[1], borderPoints.topLeftInner, borderPoints.topRightInner, bounds.left + borders[3].width, bounds.top + borders[0].width
          parseCorner borderArgs, radius[1], radius[2], borderPoints.topRightInner, borderPoints.bottomRightInner, bounds.left + bounds.width - (borders[1].width), bounds.top + borders[0].width
          parseCorner borderArgs, radius[2], radius[3], borderPoints.bottomRightInner, borderPoints.bottomLeftInner, bounds.left + bounds.width - (borders[1].width), bounds.top + bounds.height - (borders[2].width)
          parseCorner borderArgs, radius[3], radius[0], borderPoints.bottomLeftInner, borderPoints.topLeftInner, bounds.left + borders[3].width, bounds.top + bounds.height - (borders[2].width)
        else
          parseCorner borderArgs, radius[0], radius[1], borderPoints.topLeftOuter, borderPoints.topRightOuter, bounds.left, bounds.top
          parseCorner borderArgs, radius[1], radius[2], borderPoints.topRightOuter, borderPoints.bottomRightOuter, bounds.left + bounds.width, bounds.top
          parseCorner borderArgs, radius[2], radius[3], borderPoints.bottomRightOuter, borderPoints.bottomLeftOuter, bounds.left + bounds.width, bounds.top + bounds.height
          parseCorner borderArgs, radius[3], radius[0], borderPoints.bottomLeftOuter, borderPoints.topLeftOuter, bounds.left, bounds.top + bounds.height
          break
      borderArgs

    parseBorders = (element, bounds, borders) ->
      x = bounds.left
      y = bounds.top
      width = bounds.width
      height = bounds.height
      borderSide = undefined
      bx = undefined
      borderY = undefined
      bw = undefined
      bh = undefined
      borderArgs = undefined
      borderRadius = getBorderRadiusData(element)
      borderPoints = calculateCurvePoints(bounds, borderRadius, borders)
      borderData =
        clip: getBorderClip(element, borderPoints, borders, borderRadius, bounds)
        borders: []
      borderSide = 0
      while borderSide < 4
        if borders[borderSide].width > 0
          bx = x
          borderY = y
          bw = width
          bh = height - (borders[2].width)
          switch borderSide
            when 0
              # top border
              bh = borders[0].width
              borderArgs = drawSide({
                c1: [
                  bx
                  borderY
                ]
                c2: [
                  bx + bw
                  borderY
                ]
                c3: [
                  bx + bw - (borders[1].width)
                  borderY + bh
                ]
                c4: [
                  bx + borders[3].width
                  borderY + bh
                ]
              }, borderRadius[0], borderRadius[1], borderPoints.topLeftOuter, borderPoints.topLeftInner, borderPoints.topRightOuter, borderPoints.topRightInner)
            when 1
              # right border
              bx = x + width - (borders[1].width)
              bw = borders[1].width
              borderArgs = drawSide({
                c1: [
                  bx + bw
                  borderY
                ]
                c2: [
                  bx + bw
                  borderY + bh + borders[2].width
                ]
                c3: [
                  bx
                  borderY + bh
                ]
                c4: [
                  bx
                  borderY + borders[0].width
                ]
              }, borderRadius[1], borderRadius[2], borderPoints.topRightOuter, borderPoints.topRightInner, borderPoints.bottomRightOuter, borderPoints.bottomRightInner)
            when 2
              # bottom border
              borderY = borderY + height - (borders[2].width)
              bh = borders[2].width
              borderArgs = drawSide({
                c1: [
                  bx + bw
                  borderY + bh
                ]
                c2: [
                  bx
                  borderY + bh
                ]
                c3: [
                  bx + borders[3].width
                  borderY
                ]
                c4: [
                  bx + bw - (borders[3].width)
                  borderY
                ]
              }, borderRadius[2], borderRadius[3], borderPoints.bottomRightOuter, borderPoints.bottomRightInner, borderPoints.bottomLeftOuter, borderPoints.bottomLeftInner)
            when 3
              # left border
              bw = borders[3].width
              borderArgs = drawSide({
                c1: [
                  bx
                  borderY + bh + borders[2].width
                ]
                c2: [
                  bx
                  borderY
                ]
                c3: [
                  bx + bw
                  borderY + borders[0].width
                ]
                c4: [
                  bx + bw
                  borderY + bh
                ]
              }, borderRadius[3], borderRadius[0], borderPoints.bottomLeftOuter, borderPoints.bottomLeftInner, borderPoints.topLeftOuter, borderPoints.topLeftInner)
          borderData.borders.push
            args: borderArgs
            color: borders[borderSide].color
        borderSide++
      borderData

    createShape = (ctx, args) ->
      shape = ctx.drawShape()
      args.forEach (border, index) ->
        shape[if index is 0 then 'moveTo' else border[0] + 'To'].apply null, border.slice(1)
        return
      shape

    renderBorders = (ctx, borderArgs, color) ->
      if color isnt 'transparent'
        ctx.setVariable 'fillStyle', color
        createShape ctx, borderArgs
        ctx.fill()
        numDraws += 1
      return

    renderFormValue = (el, bounds, stack) ->
      valueWrap = doc.createElement('valuewrap')
      cssPropertyArray = [
        'lineHeight'
        'textAlign'
        'fontFamily'
        'color'
        'fontSize'
        'paddingLeft'
        'paddingTop'
        'width'
        'height'
        'border'
        'borderLeftWidth'
        'borderTopWidth'
      ]
      textValue = undefined
      textNode = undefined
      cssPropertyArray.forEach (property) ->
        try
          valueWrap.style[property] = getCSS(el, property)
        catch e
          # Older IE has issues with "border"
          Util.log 'html2canvas: Parse: Exception caught in renderFormValue: ' + e.message
        return
      valueWrap.style.borderColor = 'black'
      valueWrap.style.borderStyle = 'solid'
      valueWrap.style.display = 'block'
      valueWrap.style.position = 'absolute'
      if /^(submit|reset|button|text|password)$/.test(el.type) or el.nodeName is 'SELECT'
        valueWrap.style.lineHeight = getCSS(el, 'height')
      valueWrap.style.top = bounds.top + 'px'
      valueWrap.style.left = bounds.left + 'px'
      textValue = if el.nodeName is 'SELECT' then (el.options[el.selectedIndex] or 0).text else el.value
      if not textValue
        textValue = el.placeholder
      textNode = doc.createTextNode(textValue)
      valueWrap.appendChild textNode
      body.appendChild valueWrap
      renderText el, textNode, stack
      body.removeChild valueWrap
      return

    drawImage = (ctx) ->
      ctx.drawImage.apply ctx, Array::slice.call(arguments, 1)
      numDraws += 1
      return

    getPseudoElement = (el, which) ->
      elStyle = window.getComputedStyle(el, which)
      if not elStyle or not elStyle.content or elStyle.content is 'none' or elStyle.content is '-moz-alt-content' or elStyle.display is 'none'
        return
      content = elStyle.content + ''
      first = content.substr(0, 1)
      #strips quotes
      if first is content.substr(content.length - 1) and first.match(/'|"/)
        content = content.substr(1, content.length - 2)
      isImage = content.substr(0, 3) is 'url'
      elps = document.createElement(if isImage then 'img' else 'span')
      elps.className = pseudoHide + '-before ' + pseudoHide + '-after'
      Object.keys(elStyle).filter(indexedProperty).forEach (prop) ->
        # Prevent assigning of read only CSS Rules, ex. length, parentRule
        try
          elps.style[prop] = elStyle[prop]
        catch e
          Util.log [
            'Tried to assign readonly property '
            prop
            'Error:'
            e
          ]
        return
      if isImage
        elps.src = Util.parseBackgroundImage(content)[0].args[0]
      else
        elps.innerHTML = content
      elps

    indexedProperty = (property) ->
      isNaN window.parseInt(property, 10)

    injectPseudoElements = (el, stack) ->
      before = getPseudoElement(el, ':before')
      after = getPseudoElement(el, ':after')
      if not before and not after
        return
      if before
        el.className += ' ' + pseudoHide + '-before'
        el.parentNode.insertBefore before, el
        parseElement before, stack, true
        el.parentNode.removeChild before
        el.className = el.className.replace(pseudoHide + '-before', '').trim()
      if after
        el.className += ' ' + pseudoHide + '-after'
        el.appendChild after
        parseElement after, stack, true
        el.removeChild after
        el.className = el.className.replace(pseudoHide + '-after', '').trim()
      return

    renderBackgroundRepeat = (ctx, image, backgroundPosition, bounds) ->
      offsetX = Math.round(bounds.left + backgroundPosition.left)
      offsetY = Math.round(bounds.top + backgroundPosition.top)
      ctx.createPattern image
      ctx.translate offsetX, offsetY
      ctx.fill()
      ctx.translate -offsetX, -offsetY
      return

    backgroundRepeatShape = (ctx, image, backgroundPosition, bounds, left, top, width, height) ->
      args = []
      args.push [
        'line'
        Math.round(left)
        Math.round(top)
      ]
      args.push [
        'line'
        Math.round(left + width)
        Math.round(top)
      ]
      args.push [
        'line'
        Math.round(left + width)
        Math.round(height + top)
      ]
      args.push [
        'line'
        Math.round(left)
        Math.round(height + top)
      ]
      createShape ctx, args
      ctx.save()
      ctx.clip()
      renderBackgroundRepeat ctx, image, backgroundPosition, bounds
      ctx.restore()
      return

    renderBackgroundColor = (ctx, backgroundBounds, bgcolor) ->
      renderRect ctx, backgroundBounds.left, backgroundBounds.top, backgroundBounds.width, backgroundBounds.height, bgcolor
      return

    renderBackgroundRepeating = (el, bounds, ctx, image, imageIndex) ->
      backgroundSize = Util.BackgroundSize(el, bounds, image, imageIndex)
      backgroundPosition = Util.BackgroundPosition(el, bounds, image, imageIndex, backgroundSize)
      backgroundRepeat = getCSS(el, 'backgroundRepeat').split(',').map(Util.trimText)
      image = resizeImage(image, backgroundSize)
      backgroundRepeat = backgroundRepeat[imageIndex] or backgroundRepeat[0]
      switch backgroundRepeat
        when 'repeat-x'
          backgroundRepeatShape ctx, image, backgroundPosition, bounds, bounds.left, bounds.top + backgroundPosition.top, 99999, image.height
        when 'repeat-y'
          backgroundRepeatShape ctx, image, backgroundPosition, bounds, bounds.left + backgroundPosition.left, bounds.top, image.width, 99999
        when 'no-repeat'
          backgroundRepeatShape ctx, image, backgroundPosition, bounds, bounds.left + backgroundPosition.left, bounds.top + backgroundPosition.top, image.width, image.height
        else
          renderBackgroundRepeat ctx, image, backgroundPosition,
            top: bounds.top
            left: bounds.left
            width: image.width
            height: image.height
          break
      return

    renderBackgroundImage = (element, bounds, ctx) ->
      backgroundImage = getCSS(element, 'backgroundImage')
      backgroundImages = Util.parseBackgroundImage(backgroundImage)
      image = undefined
      imageIndex = backgroundImages.length
      while imageIndex--
        backgroundImage = backgroundImages[imageIndex]
        if not backgroundImage.args or backgroundImage.args.length is 0
          borderSide++
          continue
        key = if backgroundImage.method is 'url' then backgroundImage.args[0] else backgroundImage.value
        image = loadImage(key)
        # TODO add support for background-origin
        if image
          renderBackgroundRepeating element, bounds, ctx, image, imageIndex
        else
          Util.log 'html2canvas: Error loading background:', backgroundImage
      return

    resizeImage = (image, bounds) ->
      if image.width is bounds.width and image.height is bounds.height
        return image
      ctx = undefined
      canvas = doc.createElement('canvas')
      canvas.width = bounds.width
      canvas.height = bounds.height
      ctx = canvas.getContext('2d')
      drawImage ctx, image, 0, 0, image.width, image.height, 0, 0, bounds.width, bounds.height
      canvas

    setOpacity = (ctx, element, parentStack) ->
      ctx.setVariable 'globalAlpha', getCSS(element, 'opacity') * (if parentStack then parentStack.opacity else 1)

    removePx = (str) ->
      str.replace 'px', ''

    getTransform = (element, parentStack) ->
      transform = getCSS(element, 'transform') or getCSS(element, '-webkit-transform') or getCSS(element, '-moz-transform') or getCSS(element, '-ms-transform') or getCSS(element, '-o-transform')
      transformOrigin = getCSS(element, 'transform-origin') or getCSS(element, '-webkit-transform-origin') or getCSS(element, '-moz-transform-origin') or getCSS(element, '-ms-transform-origin') or getCSS(element, '-o-transform-origin') or '0px 0px'
      transformOrigin = transformOrigin.split(' ').map(removePx).map(Util.asFloat)
      matrix = undefined
      if transform and transform isnt 'none'
        match = transform.match(transformRegExp)
        if match
          switch match[1]
            when 'matrix'
              matrix = match[2].split(',').map(Util.trimText).map(Util.asFloat)
      {
        origin: transformOrigin
        matrix: matrix
      }

    createStack = (element, parentStack, bounds, transform) ->
      ctx = h2cRenderContext((if not parentStack then documentWidth() else bounds.width), (if not parentStack then documentHeight() else bounds.height))
      stack =
        ctx: ctx
        opacity: setOpacity(ctx, element, parentStack)
        cssPosition: getCSS(element, 'position')
        borders: getBorderData(element)
        transform: transform
        clip: if parentStack and parentStack.clip then Util.Extend({}, parentStack.clip) else null
      setZ element, stack, parentStack
      # TODO correct overflow for absolute content residing under a static position
      if options.useOverflow is true and /(hidden|scroll|auto)/.test(getCSS(element, 'overflow')) is true and /(BODY)/i.test(element.nodeName) is false
        stack.clip = if stack.clip then clipBounds(stack.clip, bounds) else bounds
      stack

    getBackgroundBounds = (borders, bounds, clip) ->
      backgroundBounds =
        left: bounds.left + borders[3].width
        top: bounds.top + borders[0].width
        width: bounds.width - (borders[1].width + borders[3].width)
        height: bounds.height - (borders[0].width + borders[2].width)
      if clip
        backgroundBounds = clipBounds(backgroundBounds, clip)
      backgroundBounds

    getBounds = (element, transform) ->
      bounds = if transform.matrix then Util.OffsetBounds(element) else Util.Bounds(element)
      transform.origin[0] += bounds.left
      transform.origin[1] += bounds.top
      bounds

    renderElement = (element, parentStack, pseudoElement, ignoreBackground) ->
      transform = getTransform(element, parentStack)
      bounds = getBounds(element, transform)
      image = undefined
      stack = createStack(element, parentStack, bounds, transform)
      borders = stack.borders
      ctx = stack.ctx
      backgroundBounds = getBackgroundBounds(borders, bounds, stack.clip)
      borderData = parseBorders(element, bounds, borders)
      backgroundColor = if ignoreElementsRegExp.test(element.nodeName) then '#efefef' else getCSS(element, 'backgroundColor')
      createShape ctx, borderData.clip
      ctx.save()
      ctx.clip()
      if backgroundBounds.height > 0 and backgroundBounds.width > 0 and not ignoreBackground
        renderBackgroundColor ctx, bounds, backgroundColor
        renderBackgroundImage element, backgroundBounds, ctx
      else if ignoreBackground
        stack.backgroundColor = backgroundColor
      ctx.restore()
      borderData.borders.forEach (border) ->
        renderBorders ctx, border.args, border.color
        return
      if not pseudoElement
        injectPseudoElements element, stack
      switch element.nodeName
        when 'IMG'
          if image = loadImage(element.getAttribute('src'))
            renderImage ctx, element, image, bounds, borders
          else
            Util.log 'html2canvas: Error loading <img>:' + element.getAttribute('src')
        when 'INPUT'
          # TODO add all relevant type's, i.e. HTML5 new stuff
          # todo add support for placeholder attribute for browsers which support it
          if /^(text|url|email|submit|button|reset)$/.test(element.type) and (element.value or element.placeholder or '').length > 0
            renderFormValue element, bounds, stack
        when 'TEXTAREA'
          if (element.value or element.placeholder or '').length > 0
            renderFormValue element, bounds, stack
        when 'SELECT'
          if (element.options or element.placeholder or '').length > 0
            renderFormValue element, bounds, stack
        when 'LI'
          renderListItem element, stack, backgroundBounds
        when 'CANVAS'
          renderImage ctx, element, element, bounds, borders
      stack

    isElementVisible = (element) ->
      getCSS(element, 'display') isnt 'none' and getCSS(element, 'visibility') isnt 'hidden' and not element.hasAttribute('data-html2canvas-ignore')

    parseElement = (element, stack, pseudoElement) ->
      if isElementVisible(element)
        stack = renderElement(element, stack, pseudoElement, false) or stack
        if not ignoreElementsRegExp.test(element.nodeName)
          parseChildren element, stack, pseudoElement
      return

    parseChildren = (element, stack, pseudoElement) ->
      Util.Children(element).forEach (node) ->
        if node.nodeType is node.ELEMENT_NODE
          parseElement node, stack, pseudoElement
        else if node.nodeType is node.TEXT_NODE
          renderText element, node, stack
        return
      return

    init = ->
      background = getCSS(document.documentElement, 'backgroundColor')
      transparentBackground = Util.isTransparent(background) and element is document.body
      stack = renderElement(element, null, false, transparentBackground)
      parseChildren element, stack
      if transparentBackground
        background = stack.backgroundColor
      body.removeChild hidePseudoElements
      {
        backgroundColor: background
        stack: stack
      }

    window.scroll 0, 0
    element = if options.elements is undefined then document.body else options.elements[0]
    numDraws = 0
    doc = element.ownerDocument
    Util = _html2canvas.Util
    support = Util.Support(options, doc)
    ignoreElementsRegExp = new RegExp('(' + options.ignoreElements + ')')
    body = doc.body
    getCSS = Util.getCSS
    pseudoHide = '___html2canvas___pseudoelement'
    hidePseudoElements = doc.createElement('style')
    hidePseudoElements.innerHTML = '.' + pseudoHide + '-before:before { content: "" !important; display: none !important; }' + '.' + pseudoHide + '-after:after { content: "" !important; display: none !important; }'
    body.appendChild hidePseudoElements
    images = images or {}
    getCurvePoints = ((kappa) ->
      (x, y, r1, r2) ->
        ox = r1 * kappa
        oy = r2 * kappa
        xm = x + r1
        ym = y + r2
        # y-middle
        {
          topLeft: bezierCurve({
            x: x
            y: ym
          }, {
            x: x
            y: ym - oy
          }, {
            x: xm - ox
            y: y
          },
            x: xm
            y: y)
          topRight: bezierCurve({
            x: x
            y: y
          }, {
            x: x + ox
            y: y
          }, {
            x: xm
            y: ym - oy
          },
            x: xm
            y: ym)
          bottomRight: bezierCurve({
            x: xm
            y: y
          }, {
            x: xm
            y: y + oy
          }, {
            x: x + ox
            y: ym
          },
            x: x
            y: ym)
          bottomLeft: bezierCurve({
            x: xm
            y: ym
          }, {
            x: xm - ox
            y: ym
          }, {
            x: x
            y: y + oy
          },
            x: x
            y: y)
        }
    )(4 * (Math.sqrt(2) - 1) / 3)
    transformRegExp = /(matrix)\((.+)\)/
    init()

  _html2canvas.Preload = (options) ->
    images =
      numLoaded: 0
      numFailed: 0
      numTotal: 0
      cleanupDone: false
    pageOrigin = undefined
    Util = _html2canvas.Util
    methods = undefined
    i = undefined
    count = 0
    element = options.elements[0] or document.body
    doc = element.ownerDocument
    domImages = element.getElementsByTagName('img')
    imgLen = domImages.length
    link = doc.createElement('a')
    supportCORS = ((img) ->
      img.crossOrigin isnt undefined
    )(new Image)
    timeoutTimer = undefined

    isSameOrigin = (url) ->
      link.href = url
      link.href = link.href
      # YES, BELIEVE IT OR NOT, that is required for IE9 - http://jsfiddle.net/niklasvh/2e48b/
      origin = link.protocol + link.host
      origin is pageOrigin

    start = ->
      Util.log 'html2canvas: start: images: ' + images.numLoaded + ' / ' + images.numTotal + ' (failed: ' + images.numFailed + ')'
      if not images.firstRun and images.numLoaded >= images.numTotal
        Util.log 'Finished loading images: # ' + images.numTotal + ' (failed: ' + images.numFailed + ')'
        if typeof options.complete is 'function'
          options.complete images
      return

    # TODO modify proxy to serve images with CORS enabled, where available

    proxyGetImage = (url, img, imageObj) ->
      callback_name = undefined
      scriptUrl = options.proxy
      script = undefined
      link.href = url
      url = link.href
      # work around for pages with base href="" set - WARNING: this may change the url
      callback_name = 'html2canvas_' + count++
      imageObj.callbackname = callback_name
      if scriptUrl.indexOf('?') > -1
        scriptUrl += '&'
      else
        scriptUrl += '?'
      scriptUrl += 'url=' + encodeURIComponent(url) + '&callback=' + callback_name
      script = doc.createElement('script')

      window[callback_name] = (a) ->
        if a.substring(0, 6) is 'error:'
          imageObj.succeeded = false
          images.numLoaded++
          images.numFailed++
          start()
        else
          setImageLoadHandlers img, imageObj
          img.src = a
        window[callback_name] = undefined
        # to work with IE<9  // NOTE: that the undefined callback property-name still exists on the window object (for IE<9)
        try
          delete window[callback_name]
          # for all browser that support this
        catch ex
        script.parentNode.removeChild script
        script = null
        delete imageObj.script
        delete imageObj.callbackname
        return

      script.setAttribute 'type', 'text/javascript'
      script.setAttribute 'src', scriptUrl
      imageObj.script = script
      window.document.body.appendChild script
      return

    loadPseudoElement = (element, type) ->
      style = window.getComputedStyle(element, type)
      content = style.content
      if content.substr(0, 3) is 'url'
        methods.loadImage _html2canvas.Util.parseBackgroundImage(content)[0].args[0]
      loadBackgroundImages style.backgroundImage, element
      return

    loadPseudoElementImages = (element) ->
      loadPseudoElement element, ':before'
      loadPseudoElement element, ':after'
      return

    loadGradientImage = (backgroundImage, bounds) ->
      img = _html2canvas.Generate.Gradient(backgroundImage, bounds)
      if img isnt undefined
        images[backgroundImage] =
          img: img
          succeeded: true
        images.numTotal++
        images.numLoaded++
        start()
      return

    invalidBackgrounds = (background_image) ->
      background_image and background_image.method and background_image.args and background_image.args.length > 0

    loadBackgroundImages = (background_image, el) ->
      bounds = undefined
      _html2canvas.Util.parseBackgroundImage(background_image).filter(invalidBackgrounds).forEach (background_image) ->
        if background_image.method is 'url'
          methods.loadImage background_image.args[0]
        else if background_image.method.match(/\-?gradient$/)
          if bounds is undefined
            bounds = _html2canvas.Util.Bounds(el)
          loadGradientImage background_image.value, bounds
        return
      return

    getImages = (el) ->
      elNodeType = false
      # Firefox fails with permission denied on pages with iframes
      try
        Util.Children(el).forEach getImages
      catch e
      try
        elNodeType = el.nodeType
      catch ex
        elNodeType = false
        Util.log 'html2canvas: failed to access some element\'s nodeType - Exception: ' + ex.message
      if elNodeType is 1 or elNodeType is undefined
        loadPseudoElementImages el
        try
          loadBackgroundImages Util.getCSS(el, 'backgroundImage'), el
        catch e
          Util.log 'html2canvas: failed to get background-image - Exception: ' + e.message
        loadBackgroundImages el
      return

    setImageLoadHandlers = (img, imageObj) ->

      img.onload = ->
        if imageObj.timer isnt undefined
          # CORS succeeded
          window.clearTimeout imageObj.timer
        images.numLoaded++
        imageObj.succeeded = true
        img.onerror = img.onload = null
        start()
        return

      img.onerror = ->
        if img.crossOrigin is 'anonymous'
          # CORS failed
          window.clearTimeout imageObj.timer
          # let's try with proxy instead
          if options.proxy
            src = img.src
            img = new Image
            imageObj.img = img
            img.src = src
            proxyGetImage img.src, img, imageObj
            return
        images.numLoaded++
        images.numFailed++
        imageObj.succeeded = false
        img.onerror = img.onload = null
        start()
        return

      return

    link.href = window.location.href
    pageOrigin = link.protocol + link.host
    methods =
      loadImage: (src) ->
        img = undefined
        imageObj = undefined
        if src and images[src] is undefined
          img = new Image
          if src.match(/data:image\/.*;base64,/i)
            img.src = src.replace(/url\(['"]{0,}|['"]{0,}\)$/ig, '')
            imageObj = images[src] = img: img
            images.numTotal++
            setImageLoadHandlers img, imageObj
          else if isSameOrigin(src) or options.allowTaint is true
            imageObj = images[src] = img: img
            images.numTotal++
            setImageLoadHandlers img, imageObj
            img.src = src
          else if supportCORS and not options.allowTaint and options.useCORS
            # attempt to load with CORS
            img.crossOrigin = 'anonymous'
            imageObj = images[src] = img: img
            images.numTotal++
            setImageLoadHandlers img, imageObj
            img.src = src
          else if options.proxy
            imageObj = images[src] = img: img
            images.numTotal++
            proxyGetImage src, img, imageObj
        return
      cleanupDOM: (cause) ->
        img = undefined
        src = undefined
        if not images.cleanupDone
          if cause and typeof cause is 'string'
            Util.log 'html2canvas: Cleanup because: ' + cause
          else
            Util.log 'html2canvas: Cleanup after timeout: ' + options.timeout + ' ms.'
          for src in images
            # `src = src`
            if images.hasOwnProperty(src)
              img = images[src]
              if typeof img is 'object' and img.callbackname and img.succeeded is undefined
                # cancel proxy image request
                window[img.callbackname] = undefined
                # to work with IE<9  // NOTE: that the undefined callback property-name still exists on the window object (for IE<9)
                try
                  delete window[img.callbackname]
                  # for all browser that support this
                catch ex
                if img.script and img.script.parentNode
                  img.script.setAttribute 'src', 'about:blank'
                  # try to cancel running request
                  img.script.parentNode.removeChild img.script
                images.numLoaded++
                images.numFailed++
                Util.log 'html2canvas: Cleaned up failed img: \'' + src + '\' Steps: ' + images.numLoaded + ' / ' + images.numTotal
          # cancel any pending requests
          if window.stop isnt undefined
            window.stop()
          else if document.execCommand isnt undefined
            document.execCommand 'Stop', false
          if document.close isnt undefined
            document.close()
          images.cleanupDone = true
          if not (cause and typeof cause is 'string')
            start()
        return
      renderingDone: ->
        if timeoutTimer
          window.clearTimeout timeoutTimer
        return
    if options.timeout > 0
      timeoutTimer = window.setTimeout(methods.cleanupDOM, options.timeout)
    Util.log 'html2canvas: Preload starts: finding background-images'
    images.firstRun = true
    getImages element
    Util.log 'html2canvas: Preload: Finding images'
    # load <img> images
    i = 0
    while i < imgLen
      methods.loadImage domImages[i].getAttribute('src')
      i += 1
    images.firstRun = false
    Util.log 'html2canvas: Preload: Done.'
    if images.numTotal is images.numLoaded
      start()
    methods

  _html2canvas.Renderer = (parseQueue, options) ->
    # http://www.w3.org/TR/CSS21/zindex.html

    createRenderQueue = (parseQueue) ->
      queue = []
      rootContext = undefined

      sortZ = (context) ->
        Object.keys(context).sort().forEach (zi) ->
          nonPositioned = []
          floated = []
          positioned = []
          list = []
          # positioned after static
          context[zi].forEach (v) ->
            if v.node.zIndex.isPositioned or v.node.zIndex.opacity < 1
              # http://www.w3.org/TR/css3-color/#transparency
              # non-positioned element with opactiy < 1 should be stacked as if it were a positioned element with ‘z-index: 0’ and ‘opacity: 1’.
              positioned.push v
            else if v.node.zIndex.isFloated
              floated.push v
            else
              nonPositioned.push v
            return

          do walk = (arr = nonPositioned.concat(floated, positioned)) ->
            arr.forEach (v) ->
              list.push v
              if v.children
                walk v.children
                return
              return

          list.forEach (v) ->
            if v.context
              sortZ v.context
            else
              queue.push v.node
            return
          return
        return

      rootContext = ((rootNode) ->
        # `var rootContext`
        irootContext = {}

        insert = (context, node, specialParent) ->
          zi = if node.zIndex.zindex is 'auto' then 0 else Number(node.zIndex.zindex)
          contextForChildren = context
          isPositioned = node.zIndex.isPositioned
          isFloated = node.zIndex.isFloated
          stub = node: node
          childrenDest = specialParent
          # where children without z-index should be pushed into
          if node.zIndex.ownStacking
            # '!' comes before numbers in sorted array
            contextForChildren = stub.context = '!': [ {
              node: node
              children: []
            } ]
            childrenDest = undefined
          else if isPositioned or isFloated
            childrenDest = stub.children = []
          if zi is 0 and specialParent
            specialParent.push stub
          else
            if not context[zi]
              context[zi] = []
            context[zi].push stub
          node.zIndex.children.forEach (childNode) ->
            insert contextForChildren, childNode, childrenDest
            return
          return

        insert irootContext, rootNode
        irootContext
      )(parseQueue)
      sortZ rootContext
      queue

    getRenderer = (rendererName) ->
      renderer = undefined
      if typeof options.renderer is 'string' and _html2canvas.Renderer[rendererName] isnt undefined
        renderer = _html2canvas.Renderer[rendererName](options)
      else if typeof rendererName is 'function'
        renderer = rendererName(options)
      else
        throw new Error('Unknown renderer')
      if typeof renderer isnt 'function'
        throw new Error('Invalid renderer defined')
      renderer

    getRenderer(options.renderer) parseQueue, options, document, createRenderQueue(parseQueue.stack), _html2canvas

  _html2canvas.Util.Support = (options, doc) ->

    supportSVGRendering = ->
      img = new Image
      canvas = doc.createElement('canvas')
      ctx = if canvas.getContext is undefined then false else canvas.getContext('2d')
      if ctx is false
        return false
      canvas.width = canvas.height = 10
      img.src = [
        'data:image/svg+xml,'
        '<svg xmlns=\'http://www.w3.org/2000/svg\' width=\'10\' height=\'10\'>'
        '<foreignObject width=\'10\' height=\'10\'>'
        '<div xmlns=\'http://www.w3.org/1999/xhtml\' style=\'width:10;height:10;\'>'
        'sup'
        '</div>'
        '</foreignObject>'
        '</svg>'
      ].join('')
      try
        ctx.drawImage img, 0, 0
        canvas.toDataURL()
      catch e
        return false
      _html2canvas.Util.log 'html2canvas: Parse: SVG powered rendering available'
      true

    # Test whether we can use ranges to measure bounding boxes
    # Opera doesn't provide valid bounds.height/bottom even though it supports the method.

    supportRangeBounds = ->
      r = undefined
      testElement = undefined
      rangeBounds = undefined
      rangeHeight = undefined
      support = false
      if doc.createRange
        r = doc.createRange()
        if r.getBoundingClientRect
          testElement = doc.createElement('boundtest')
          testElement.style.height = '123px'
          testElement.style.display = 'block'
          doc.body.appendChild testElement
          r.selectNode testElement
          rangeBounds = r.getBoundingClientRect()
          rangeHeight = rangeBounds.height
          if rangeHeight is 123
            support = true
          doc.body.removeChild testElement
      support

    {
      rangeBounds: supportRangeBounds()
      svgRendering: options.svgRendering and supportSVGRendering()
    }

  window.html2canvas = (elements, opts) ->
    elements = if elements.length then elements else [ elements ]
    queue = undefined
    canvas = undefined
    options =
      logging: false
      elements: elements
      background: '#fff'
      proxy: null
      timeout: 0
      useCORS: false
      allowTaint: false
      svgRendering: false
      ignoreElements: 'IFRAME|OBJECT|PARAM'
      useOverflow: true
      letterRendering: false
      chinese: false
      width: null
      height: null
      taintTest: true
      renderer: 'Canvas'
    options = _html2canvas.Util.Extend(opts, options)
    _html2canvas.logging = options.logging

    options.complete = (images) ->
      if typeof options.onpreloaded is 'function'
        if options.onpreloaded(images) is false
          return
      queue = _html2canvas.Parse(images, options)
      if typeof options.onparsed is 'function'
        if options.onparsed(queue) is false
          return
      canvas = _html2canvas.Renderer(queue, options)
      if typeof options.onrendered is 'function'
        options.onrendered canvas
      return

    # for pages without images, we still want this to be async, i.e. return methods before executing
    window.setTimeout (->
      _html2canvas.Preload options
      return
    ), 0
    {
      render: (queue, opts) ->
        _html2canvas.Renderer queue, _html2canvas.Util.Extend(opts, options)
      parse: (images, opts) ->
        _html2canvas.Parse images, _html2canvas.Util.Extend(opts, options)
      preload: (opts) ->
        _html2canvas.Preload _html2canvas.Util.Extend(opts, options)
      log: _html2canvas.Util.log
    }

  window.html2canvas.log = _html2canvas.Util.log
  # for renderers
  window.html2canvas.Renderer = Canvas: undefined

  _html2canvas.Renderer.Canvas = (options) ->

    createShape = (ctx, args) ->
      ctx.beginPath()
      args.forEach (arg) ->
        ctx[arg.name].apply ctx, arg['arguments']
        return
      ctx.closePath()
      return

    safeImage = (item) ->
      if safeImages.indexOf(item['arguments'][0].src) is -1
        testctx.drawImage item['arguments'][0], 0, 0
        try
          testctx.getImageData 0, 0, 1, 1
        catch e
          testCanvas = doc.createElement('canvas')
          testctx = testCanvas.getContext('2d')
          return false
        safeImages.push item['arguments'][0].src
      true

    renderItem = (ctx, item) ->
      switch item.type
        when 'variable'
          ctx[item.name] = item['arguments']
        when 'function'
          switch item.name
            when 'createPattern'
              if item['arguments'][0].width > 0 and item['arguments'][0].height > 0
                try
                  ctx.fillStyle = ctx.createPattern(item['arguments'][0], 'repeat')
                catch e
                  Util.log 'html2canvas: Renderer: Error creating pattern', e.message
            when 'drawShape'
              createShape ctx, item['arguments']
            when 'drawImage'
              if item['arguments'][8] > 0 and item['arguments'][7] > 0
                if not options.taintTest or options.taintTest and safeImage(item)
                  ctx.drawImage.apply ctx, item['arguments']
            else
              ctx[item.name].apply ctx, item['arguments']
      return

    options = options or {}
    doc = document
    safeImages = []
    testCanvas = document.createElement('canvas')
    testctx = testCanvas.getContext('2d')
    Util = _html2canvas.Util
    canvas = options.canvas or doc.createElement('canvas')
    (parsedData, options, document, queue, _html2canvas) ->
      ctx = canvas.getContext('2d')
      newCanvas = undefined
      bounds = undefined
      fstyle = undefined
      zStack = parsedData.stack
      canvas.width = canvas.style.width = options.width or zStack.ctx.width
      canvas.height = canvas.style.height = options.height or zStack.ctx.height
      fstyle = ctx.fillStyle
      ctx.fillStyle = if Util.isTransparent(zStack.backgroundColor) and options.background isnt undefined then options.background else parsedData.backgroundColor
      ctx.fillRect 0, 0, canvas.width, canvas.height
      ctx.fillStyle = fstyle
      queue.forEach (storageContext) ->
        # set common settings for canvas
        ctx.textBaseline = 'bottom'
        ctx.save()
        if storageContext.transform.matrix
          ctx.translate storageContext.transform.origin[0], storageContext.transform.origin[1]
          ctx.transform.apply ctx, storageContext.transform.matrix
          ctx.translate -storageContext.transform.origin[0], -storageContext.transform.origin[1]
        if storageContext.clip
          ctx.beginPath()
          ctx.rect storageContext.clip.left, storageContext.clip.top, storageContext.clip.width, storageContext.clip.height
          ctx.clip()
        if storageContext.ctx.storage
          storageContext.ctx.storage.forEach (item) ->
            renderItem ctx, item
            return
        ctx.restore()
        return
      Util.log 'html2canvas: Renderer: Canvas renderer done - returning canvas obj'
      if options.elements.length is 1
        if typeof options.elements[0] is 'object' and options.elements[0].nodeName isnt 'BODY'
          # crop image to the bounds of selected (single) element
          bounds = _html2canvas.Util.Bounds(options.elements[0])
          newCanvas = document.createElement('canvas')
          newCanvas.width = Math.ceil(bounds.width)
          newCanvas.height = Math.ceil(bounds.height)
          ctx = newCanvas.getContext('2d')
          ctx.drawImage canvas, bounds.left, bounds.top, bounds.width, bounds.height, 0, 0, bounds.width, bounds.height
          canvas = null
          return newCanvas
      canvas

  return
) window, document

module.exports = window.html2canvas
