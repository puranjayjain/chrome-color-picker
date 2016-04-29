helper = require '../helper/helper'
html2canvas = require '../helper/html2canvas'

module.exports =
class Picker extends helper
  state: off
  canvas: null
  picker: null
  onMousemove: null
  color: 'rgba(0, 0, 0, 0)'

  constructor: ->
    # from spectrum.js in chrome dev tools app
    # this code's help from http://stackoverflow.com/questions/20539196/creating-svg-elements-dynamically-with-javascript-inside-html
    @component = document.createElementNS 'http://www.w3.org/2000/svg', 'svg'
    @component.setAttribute 'xmlns:xlink', 'http://www.w3.org/1999/xlink'
    @component.setAttribute 'viewBox', '0 0 512 512'
    @component.setAttribute 'height', '16'
    @component.setAttribute 'width', '16'
    @component.id = 'ccp_picker_tool'
    path = document.createElementNS @component.namespaceURI, 'path'
    d1 = 'M493.255 18.745c-24.994-24.993-65.516-24.993-90.51 0l-86.059 86.059-60.686-60.686-67.882 67.882 53.213 53.213-236.059 236.059c-4.024 4.024-5.734 9.479-5.15 14.728h-0.122v80c0 8.837 7.164 16 16 '
    d2 = '16h80c0 0 1.332 0 2 0 4.606 0 9.213-1.758 12.728-5.272l236.059-236.059 53.213 53.213 67.882-67.882-60.686-60.686 86.059-86.059c24.993-24.994 24.993-65.516 0-90.51zM86.545 '
    d3 = '480h-54.545v-54.545l234.787-234.786 54.544 54.544-234.786 234.787z'
    path.setAttribute 'd', d1 + d2 + d3
    @setFocusable @component
    @component.appendChild path
    # add event listener to the picker to trigger open/close
    @component.addEventListener 'click', =>
      @toggle()

  # add event listeners
  attachEventListeners: ->
    # event to close the dialog on atom resize
    @onMousemove = (e) =>
      @canvas = document.getElementById 'ccp-canvas'
      updateUI = =>
        color = [0, 0, 0, 0]
        # position zoom and add color
        if @canvas?
          # https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Pixel_manipulation_with_canvas#A_color_picker
          color = @canvas.getContext('2d').getImageData(e.pageX, e.pageY, 1, 1).data
        # update the global color definition
        @color = "rgba(#{color[0]}, #{color[1]}, #{color[2]}, #{Math.floor(color[3] / 255)})"
        # window size
        windowSize = atom.getSize()
        # keep the x and y in bounds
        x = e.x + 20
        y = e.y + 20
        # NOTE
        # no need to calculate as the size is fixed to 75 also subtract some extra width
        if (x + 120) > windowSize.width
          x = windowSize.width - 120
        if (y + 170) > windowSize.height
          y = windowSize.height - 170
        @picker.setAttribute 'style', "background: #{@color};transform: translate3d(#{x}px, #{y}px, 0)"
      # https://css-tricks.com/using-requestanimationframe/
      requestAnimationFrame updateUI

    # attach the events to the window
    window.addEventListener 'mousemove', @onMousemove, true

  # remove event listeners
  removeTempEvents: ->
    window.removeEventListener 'mousemove', @onMousemove, true

  # close if open
  close: ->
    if @state
      @toggle()

  # toggle the state of the picker
  toggle: ->
    @canvas = document.getElementById 'ccp-canvas'
    if @state
      # remove element if null
      if @canvas?
        @delete @canvas
      @removeTempEvents()
      # delete zoom
      @delete @picker
    else
      # remove element if null
      if @canvas?
        @delete @canvas
      # IDEA to pick colors
      html2canvas document.body, onrendered: (canvas) ->
        canvas.id = 'ccp-canvas'
        document.getElementsByTagName('ccp-container')[0].appendChild canvas
        return
      # add zoom
      @picker = @createComponent 'ccp-picker-zoom'
      document.body.appendChild @picker
      # attach eventlisteners
      @attachEventListeners()
    # toggle the inner variable state and class
    @state = not @state
    @component.classList.toggle 'activated'
