ColorMatchers = require './TinyColor/ColorMatchers'

# TinyColor v1.3.0
# https://github.com/bgrins/TinyColor
# Brian Grinstead, MIT License
# Converted to coffescript
# convert colors between formats

module.exports =
class TinyColor extends ColorMatchers
  tinyCounter: 0
  # Big List of Colors
  # ------------------
  # <http://www.w3.org/TR/css3-color/#svg-color>
  names: {
    aliceblue: 'f0f8ff'
    antiquewhite: 'faebd7'
    aqua: '0ff'
    aquamarine: '7fffd4'
    azure: 'f0ffff'
    beige: 'f5f5dc'
    bisque: 'ffe4c4'
    black: '000'
    blanchedalmond: 'ffebcd'
    blue: '00f'
    blueviolet: '8a2be2'
    brown: 'a52a2a'
    burlywood: 'deb887'
    burntsienna: 'ea7e5d'
    cadetblue: '5f9ea0'
    chartreuse: '7fff00'
    chocolate: 'd2691e'
    coral: 'ff7f50'
    cornflowerblue: '6495ed'
    cornsilk: 'fff8dc'
    crimson: 'dc143c'
    cyan: '0ff'
    darkblue: '00008b'
    darkcyan: '008b8b'
    darkgoldenrod: 'b8860b'
    darkgray: 'a9a9a9'
    darkgreen: '006400'
    darkgrey: 'a9a9a9'
    darkkhaki: 'bdb76b'
    darkmagenta: '8b008b'
    darkolivegreen: '556b2f'
    darkorange: 'ff8c00'
    darkorchid: '9932cc'
    darkred: '8b0000'
    darksalmon: 'e9967a'
    darkseagreen: '8fbc8f'
    darkslateblue: '483d8b'
    darkslategray: '2f4f4f'
    darkslategrey: '2f4f4f'
    darkturquoise: '00ced1'
    darkviolet: '9400d3'
    deeppink: 'ff1493'
    deepskyblue: '00bfff'
    dimgray: '696969'
    dimgrey: '696969'
    dodgerblue: '1e90ff'
    firebrick: 'b22222'
    floralwhite: 'fffaf0'
    forestgreen: '228b22'
    fuchsia: 'f0f'
    gainsboro: 'dcdcdc'
    ghostwhite: 'f8f8ff'
    gold: 'ffd700'
    goldenrod: 'daa520'
    gray: '808080'
    green: '008000'
    greenyellow: 'adff2f'
    grey: '808080'
    honeydew: 'f0fff0'
    hotpink: 'ff69b4'
    indianred: 'cd5c5c'
    indigo: '4b0082'
    ivory: 'fffff0'
    khaki: 'f0e68c'
    lavender: 'e6e6fa'
    lavenderblush: 'fff0f5'
    lawngreen: '7cfc00'
    lemonchiffon: 'fffacd'
    lightblue: 'add8e6'
    lightcoral: 'f08080'
    lightcyan: 'e0ffff'
    lightgoldenrodyellow: 'fafad2'
    lightgray: 'd3d3d3'
    lightgreen: '90ee90'
    lightgrey: 'd3d3d3'
    lightpink: 'ffb6c1'
    lightsalmon: 'ffa07a'
    lightseagreen: '20b2aa'
    lightskyblue: '87cefa'
    lightslategray: '789'
    lightslategrey: '789'
    lightsteelblue: 'b0c4de'
    lightyellow: 'ffffe0'
    lime: '0f0'
    limegreen: '32cd32'
    linen: 'faf0e6'
    magenta: 'f0f'
    maroon: '800000'
    mediumaquamarine: '66cdaa'
    mediumblue: '0000cd'
    mediumorchid: 'ba55d3'
    mediumpurple: '9370db'
    mediumseagreen: '3cb371'
    mediumslateblue: '7b68ee'
    mediumspringgreen: '00fa9a'
    mediumturquoise: '48d1cc'
    mediumvioletred: 'c71585'
    midnightblue: '191970'
    mintcream: 'f5fffa'
    mistyrose: 'ffe4e1'
    moccasin: 'ffe4b5'
    navajowhite: 'ffdead'
    navy: '000080'
    oldlace: 'fdf5e6'
    olive: '808000'
    olivedrab: '6b8e23'
    orange: 'ffa500'
    orangered: 'ff4500'
    orchid: 'da70d6'
    palegoldenrod: 'eee8aa'
    palegreen: '98fb98'
    paleturquoise: 'afeeee'
    palevioletred: 'db7093'
    papayawhip: 'ffefd5'
    peachpuff: 'ffdab9'
    peru: 'cd853f'
    pink: 'ffc0cb'
    plum: 'dda0dd'
    powderblue: 'b0e0e6'
    purple: '800080'
    rebeccapurple: '663399'
    red: 'f00'
    rosybrown: 'bc8f8f'
    royalblue: '4169e1'
    saddlebrown: '8b4513'
    salmon: 'fa8072'
    sandybrown: 'f4a460'
    seagreen: '2e8b57'
    seashell: 'fff5ee'
    sienna: 'a0522d'
    silver: 'c0c0c0'
    skyblue: '87ceeb'
    slateblue: '6a5acd'
    slategray: '708090'
    slategrey: '708090'
    snow: 'fffafa'
    springgreen: '00ff7f'
    steelblue: '4682b4'
    tan: 'd2b48c'
    teal: '008080'
    thistle: 'd8bfd8'
    tomato: 'ff6347'
    turquoise: '40e0d0'
    violet: 'ee82ee'
    wheat: 'f5deb3'
    white: 'fff'
    whitesmoke: 'f5f5f5'
    yellow: 'ff0'
    yellowgreen: '9acd32'
  }

  # Make it easy to access colors via `hexNames[hex]`
  hexNames: []

  constructor: (color = '', opts = {}) ->
    # If input is already a TinyColor, return itself
    if color instanceof TinyColor
      return color
    # If we are called as a function, call using new instead
    if not (@ instanceof TinyColor)
      return new TinyColor color, opts
    # Make it easy to access colors via `hexNames[hex]`
    @hexNames = @flip @names
    rgb = @inputToRGB color
    @_originalInput = color
    @_r = rgb.r
    @_g = rgb.g
    @_b = rgb.b
    @_a = rgb.a
    @_roundA = Math.round(100 * @_a) / 100
    @_format = opts.format or rgb.format
    @_gradientType = opts.gradientType
    # Don't let the range of [0,255] come back in [0,1].
    # Potentially lose a little bit of precision here, but will fix issues where
    # .5 gets interpreted as half of the total, instead of half of 1
    # If it was supposed to be 128, @ was already taken care of by `inputToRgb`
    if @_r < 1
      @_r = Math.round(@_r)
    if @_g < 1
      @_g = Math.round(@_g)
    if @_b < 1
      @_b = Math.round(@_b)
    @_ok = rgb.ok
    @_tc_id = @tinyCounter++
    return

  # If input is an object, force 1 into "1.0" to handle ratios properly
  # String input requires "1.0" as input, so 1 will be treated as 1
  fromRatio: (color, opts) ->
    if typeof color is 'object'
      newColor = {}
      for i of color
        if color.hasOwnProperty i
          if i is 'a'
            newColor[i] = color[i]
          else
            newColor[i] = @convertToPercentage color[i]
      color = newColor
    TinyColor color, opts

  # Given a string or object, convert that input to RGB
  # Possible string inputs:
  #
  #     "red"
  #     "#f00" or "f00"
  #     "#ff0000" or "ff0000"
  #     "#ff000000" or "ff000000"
  #     "rgb 255 0 0" or "rgb (255, 0, 0)"
  #     "rgb 1.0 0 0" or "rgb (1, 0, 0)"
  #     "rgba (255, 0, 0, 1)" or "rgba 255, 0, 0, 1"
  #     "rgba (1.0, 0, 0, 1)" or "rgba 1.0, 0, 0, 1"
  #     "hsl(0, 100%, 50%)" or "hsl 0 100% 50%"
  #     "hsla(0, 100%, 50%, 1)" or "hsla 0 100% 50%, 1"
  #     "hsv(0, 100%, 100%)" or "hsv 0 100% 100%"
  #
  inputToRGB: (color) ->
    rgb =
      r: 0
      g: 0
      b: 0
    a = 1
    ok = false
    format = false
    if typeof color is 'string'
      color = @stringInputToObject color
    if typeof color is 'object'
      if @isValidCSSUnit(color.r) and @isValidCSSUnit(color.g) and @isValidCSSUnit(color.b)
        rgb = @rgbToRgb color.r, color.g, color.b
        ok = true
        format = if String(color.r).substr(-1) is '%' then 'prgb' else 'rgb'
      else if @isValidCSSUnit(color.h) and @isValidCSSUnit(color.s) and @isValidCSSUnit(color.v)
        color.s = @convertToPercentage color.s
        color.v = @convertToPercentage color.v
        rgb = @hsvToRgb color.h, color.s, color.v
        ok = true
        format = 'hsv'
      else if @isValidCSSUnit(color.h) and @isValidCSSUnit(color.s) and @isValidCSSUnit(color.l)
        color.s = @convertToPercentage color.s
        color.l = @convertToPercentage color.l
        rgb = @hslToRgb color.h, color.s, color.l
        ok = true
        format = 'hsl'
      if color.hasOwnProperty 'a'
        a = color.a
    a = @boundAlpha a
    {
      ok: ok
      format: color.format or format
      r: Math.min(255, Math.max(rgb.r, 0))
      g: Math.min(255, Math.max(rgb.g, 0))
      b: Math.min(255, Math.max(rgb.b, 0))
      a: a
    }

  # Conversion Functions
  # --------------------
  # `@rgbToHsl`, `@rgbToHsv`, `@hslToRgb`, `@hsvToRgb` modified from:
  # <http://mjijackson.com/2008/02/rgb-to-hsl-and-rgb-to-hsv-color-model-conversion-algorithms-in-javascript>
  # `@rgbToRgb`
  # Handle bounds / percentage checking to conform to CSS color spec
  # <http://www.w3.org/TR/css3-color/>
  # *Assumes:* r, g, b in [0, 255] or [0, 1]
  # *Returns:* { r, g, b } in [0, 255]
  rgbToRgb: (r, g, b) ->
    {
      r: @bound01(r, 255) * 255
      g: @bound01(g, 255) * 255
      b: @bound01(b, 255) * 255
    }

  # `@rgbToHsl`
  # Converts an RGB color value to HSL.
  # *Assumes:* r, g, and b are contained in [0, 255] or [0, 1]
  # *Returns:* { h, s, l } in [0,1]
  rgbToHsl: (r, g, b) ->
    r = @bound01(r, 255)
    g = @bound01(g, 255)
    b = @bound01(b, 255)
    max = Math.max(r, g, b)
    min = Math.min(r, g, b)
    h = undefined
    s = undefined
    l = (max + min) / 2
    if max is min
      h = s = 0
      # achromatic
    else
      d = max - min
      s = if l > 0.5 then d / (2 - max - min) else d / (max + min)
      switch max
        when r
          h = (g - b) / d + (if g < b then 6 else 0)
        when g
          h = (b - r) / d + 2
        when b
          h = (r - g) / d + 4
      h /= 6
    {
      h: h
      s: s
      l: l
    }

  # `@hslToRgb`
  # Converts an HSL color value to RGB.
  # *Assumes:* h is contained in [0, 1] or [0, 360] and s and l are contained [0, 1] or [0, 100]
  # *Returns:* { r, g, b } in the set [0, 255]
  hslToRgb: (h, s, l) ->
    r = undefined
    g = undefined
    b = undefined

    h = @bound01(h, 360)
    s = @bound01(s, 100)
    l = @bound01(l, 100)

    if s is 0
      r = g = b = l
      # achromatic
    else
      q = if l < 0.5 then l * (1 + s) else l + s - (l * s)
      p = 2 * l - q
      r = @hue2rgb p, q, h + 1 / 3
      g = @hue2rgb p, q, h
      b = @hue2rgb p, q, h - (1 / 3)
    {
      r: r * 255
      g: g * 255
      b: b * 255
    }

  hue2rgb: (p, q, t) ->
    if t < 0
      t += 1
    if t > 1
      t -= 1
    if t < 1 / 6
      return p + (q - p) * 6 * t
    if t < 1 / 2
      return q
    if t < 2 / 3
      return p + (q - p) * (2 / 3 - t) * 6
    p

  # `@rgbToHsv`
  # Converts an RGB color value to HSV
  # *Assumes:* r, g, and b are contained in the set [0, 255] or [0, 1]
  # *Returns:* { h, s, v } in [0,1]
  rgbToHsv: (r, g, b) ->
    r = @bound01(r, 255)
    g = @bound01(g, 255)
    b = @bound01(b, 255)
    max = Math.max(r, g, b)
    min = Math.min(r, g, b)
    h = undefined
    s = undefined
    v = max
    d = max - min
    s = if max is 0 then 0 else d / max
    if max is min
      h = 0
      # achromatic
    else
      switch max
        when r
          h = (g - b) / d + (if g < b then 6 else 0)
        when g
          h = (b - r) / d + 2
        when b
          h = (r - g) / d + 4
      h /= 6
    {
      h: h
      s: s
      v: v
    }

  # `@hsvToRgb`
  # Converts an HSV color value to RGB.
  # *Assumes:* h is contained in [0, 1] or [0, 360] and s and v are contained in [0, 1] or [0, 100]
  # *Returns:* { r, g, b } in the set [0, 255]
  hsvToRgb: (h, s, v) ->
    h = @bound01(h, 360) * 6
    s = @bound01(s, 100)
    v = @bound01(v, 100)
    i = Math.floor(h)
    f = h - i
    p = v * (1 - s)
    q = v * (1 - (f * s))
    t = v * (1 - ((1 - f) * s))
    mod = i % 6
    r = [
      v
      q
      p
      p
      t
      v
    ][mod]
    g = [
      t
      v
      v
      q
      p
      p
    ][mod]
    b = [
      p
      p
      t
      v
      v
      q
    ][mod]
    {
      r: r * 255
      g: g * 255
      b: b * 255
    }

  # `@rgbToHex`
  # Converts an RGB color to hex
  # Assumes r, g, and b are contained in the set [0, 255]
  # Returns a 3 or 6 character hex
  rgbToHex: (r, g, b, allow3Char) ->
    hex = [
      @pad2(Math.round(r).toString(16))
      @pad2(Math.round(g).toString(16))
      @pad2(Math.round(b).toString(16))
    ]
    # Return a 3 character hex if possible
    if allow3Char and hex[0].charAt(0) is hex[0].charAt(1) and hex[1].charAt(0) is hex[1].charAt(1) and hex[2].charAt(0) is hex[2].charAt(1)
      return hex[0].charAt(0) + hex[1].charAt(0) + hex[2].charAt(0)
    hex.join ''

  # `@rgbaToHex`
  # Converts an RGBA color plus alpha transparency to hex
  # Assumes r, g, b and a are contained in the set [0, 255]
  # Returns an 8 character hex
  rgbaToHex: (r, g, b, a) ->
    hex = [
      @pad2(@convertDecimalToHex(a))
      @pad2(Math.round(r).toString(16))
      @pad2(Math.round(g).toString(16))
      @pad2(Math.round(b).toString(16))
    ]
    hex.join ''

  # Utilities
  # ---------
  # `{ 'name1': 'val1' }` becomes `{ 'val1': 'name1' }`
  flip: (o) ->
    flipped = {}
    for i of o
      if o.hasOwnProperty(i)
        flipped[o[i]] = i
    flipped

  # Return a valid alpha value [0,1] with all invalid values being set to 1
  boundAlpha: (a) ->
    a = parseFloat(a)
    if isNaN(a) or a < 0 or a > 1
      a = 1
    a

  # Take input from [0, n] and return it as [0, 1]
  bound01: (n, max) ->
    if @isOnePointZero(n)
      n = '100%'
    processPercent = @isPercentage(n)
    n = Math.min(max, Math.max(0, parseFloat(n)))
    # Automatically convert percentage into number
    if processPercent
      n = parseInt(n * max, 10) / 100
    # Handle floating point rounding errors
    if Math.abs(n - max) < 0.000001
      return 1
    # Convert into [0, 1] range if it isn't already
    n % max / parseFloat(max)

  # Force a number between 0 and 1
  clamp01: (val) ->
    Math.min 1, Math.max(0, val)

  # Parse a base-16 hex value into a base-10 integer
  parseIntFromHex: (val) ->
    parseInt val, 16

  # Need to handle 1.0 as 100%, since once it is a number, there is no difference between it and 1
  # <http://stackoverflow.com/questions/7422072/javascript-how-to-detect-number-as-a-decimal-including-1-0>
  isOnePointZero: (n) ->
    typeof n is 'string' and n.indexOf('.') isnt -1 and parseFloat(n) is 1

  # Check to see if string passed in is a percentage
  isPercentage: (n) ->
    typeof n is 'string' and n.indexOf('%') isnt -1

  # Force a hex value to have 2 characters
  pad2: (c) ->
    if c.length is 1 then "0#{c}" else "#{c}"

  # Replace a decimal with it's percentage value
  convertToPercentage: (n) ->
    if n <= 1
      n = "#{n * 100}%"
    n

  # Converts a decimal to a hex value
  convertDecimalToHex: (d) ->
    Math.round(parseFloat(d) * 255).toString 16

  # Converts a hex value to a decimal
  convertHexToDecimal: (h) ->
    @parseIntFromHex(h) / 255

  # `@isValidCSSUnit`
  # Take in a single string / number and check to see if it looks like a CSS unit
  # (see `matchers` above for definition).
  isValidCSSUnit: (color) ->
    !! @matchers.CSS_UNIT.exec color

  # `@stringInputToObject`
  # Permissive string parsing.  Take in a number of formats, and output an object
  # based on detected format.  Returns `{ r, g, b }` or `{ h, s, l }` or `{ h, s, v}`
  stringInputToObject: (color) ->
    color = color.replace(/^\s+/, '').replace(/\s+$/, '').toLowerCase()
    named = false
    if @names[color]
      color = @names[color]
      named = true
    else if color is 'transparent'
      return {
        r: 0
        g: 0
        b: 0
        a: 0
        format: 'name'
      }
    # Try to match string input using regular expressions.
    # Keep most of the number bounding out of @ function - don't worry about [0,1] or [0,100] or [0,360]
    # Just return an object and let the conversion functions handle that.
    # @ way the result will be the same whether the TinyColor is initialized with string or object.
    match = undefined
    if match = @matchers.rgb.exec(color)
      return {
        r: match[1]
        g: match[2]
        b: match[3]
      }
    if match = @matchers.rgba.exec(color)
      return {
        r: match[1]
        g: match[2]
        b: match[3]
        a: match[4]
      }
    if match = @matchers.hsl.exec(color)
      return {
        h: match[1]
        s: match[2]
        l: match[3]
      }
    if match = @matchers.hsla.exec(color)
      return {
        h: match[1]
        s: match[2]
        l: match[3]
        a: match[4]
      }
    if match = @matchers.hsv.exec(color)
      return {
        h: match[1]
        s: match[2]
        v: match[3]
      }
    if match = @matchers.hsva.exec(color)
      return {
        h: match[1]
        s: match[2]
        v: match[3]
        a: match[4]
      }
    if match = @matchers.hex8.exec(color)
      return {
        a: @convertHexToDecimal(match[1])
        r: @parseIntFromHex(match[2])
        g: @parseIntFromHex(match[3])
        b: @parseIntFromHex(match[4])
        format: if named then 'name' else 'hex8'
      }
    if match = @matchers.hex6.exec(color)
      return {
        r: @parseIntFromHex(match[1])
        g: @parseIntFromHex(match[2])
        b: @parseIntFromHex(match[3])
        format: if named then 'name' else 'hex'
      }
    if match = @matchers.hex3.exec(color)
      return {
        r: @parseIntFromHex(match[1] + '' + match[1])
        g: @parseIntFromHex(match[2] + '' + match[2])
        b: @parseIntFromHex(match[3] + '' + match[3])
        format: if named then 'name' else 'hex'
      }
    false

  isDark: ->
    @getBrightness() < 128

  isLight: ->
    not @isDark()

  isValid: ->
    @_ok

  getOriginalInput: ->
    @_originalInput

  getFormat: ->
    @_format

  getAlpha: ->
    @_a

  getBrightness: ->
    #http://www.w3.org/TR/AERT#color-contrast
    rgb = @toRgb()
    (rgb.r * 299 + rgb.g * 587 + rgb.b * 114) / 1000

  getLuminance: ->
    #http://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
    rgb = @toRgb()
    RsRGB = undefined
    GsRGB = undefined
    BsRGB = undefined
    R = undefined
    G = undefined
    B = undefined
    RsRGB = rgb.r / 255
    GsRGB = rgb.g / 255
    BsRGB = rgb.b / 255
    if RsRGB <= 0.03928
      R = RsRGB / 12.92
    else
      R = ((RsRGB + 0.055) / 1.055) ** 2.4
    if GsRGB <= 0.03928
      G = GsRGB / 12.92
    else
      G = ((GsRGB + 0.055) / 1.055) ** 2.4
    if BsRGB <= 0.03928
      B = BsRGB / 12.92
    else
      B = ((BsRGB + 0.055) / 1.055) ** 2.4
    0.2126 * R + 0.7152 * G + 0.0722 * B

  setAlpha: (value) ->
    @_a = @boundAlpha(value)
    @_roundA = Math.round(100 * @_a) / 100
    @

  toHsv: ->
    hsv = @rgbToHsv(@_r, @_g, @_b)
    {
      h: hsv.h * 360
      s: hsv.s
      v: hsv.v
      a: @_a
    }

  toHsvString: ->
    hsv = @rgbToHsv(@_r, @_g, @_b)
    h = Math.round(hsv.h * 360)
    s = Math.round(hsv.s * 100)
    v = Math.round(hsv.v * 100)
    if @_a is 1 then "hsv(#{h}, #{s}%, #{v}%)" else "hsva(#{h}, #{s}%, #{v}%, #{@_roundA})"

  toHsl: ->
    hsl = @rgbToHsl(@_r, @_g, @_b)
    {
      h: hsl.h * 360
      s: hsl.s
      l: hsl.l
      a: @_a
    }

  toHslString: ->
    hsl = @rgbToHsl(@_r, @_g, @_b)
    h = Math.round(hsl.h * 360)
    s = Math.round(hsl.s * 100)
    l = Math.round(hsl.l * 100)
    if @_a is 1 then "hsl(#{h}, #{s}%, #{l}%)" else "hsla(#{h}, #{s}%, #{l}%, #{@_roundA})"

  toRatioHslString: ->
    hsl = @rgbToHsl(@_r, @_g, @_b)
    h = Math.round(hsl.h * 360)
    s = Math.round(hsl.s)
    l = Math.round(hsl.l)
    if @_a is 1 then "hsl(#{h}, #{s}, #{l})" else "hsla(#{h}, #{s}, #{l}, #{@_roundA})"

  toHex: (allow3Char) ->
    @rgbToHex @_r, @_g, @_b, allow3Char

  toHexString: (allow3Char) ->
    "##{@toHex(allow3Char)}"

  toHex8: ->
    @rgbaToHex @_r, @_g, @_b, @_a

  toHex8String: ->
    "##{@toHex8()}"

  toRgb: ->
    # fix to make them below 255
    c_r = Math.round(@_r)
    c_g = Math.round(@_g)
    c_b = Math.round(@_b)
    if c_r > 255
      c_r = 255
    if c_g > 255
      c_g = 255
    if c_b > 255
      c_ b = 255
    {
      r: c_r
      g: c_g
      b: c_b
      a: @_a
    }

  toRgbString: ->
    if @_a is 1 then "rgb(#{Math.round(@_r)}, #{Math.round(@_g)}, #{Math.round(@_b)})" else "rgba(#{Math.round(@_r)}, #{Math.round(@_g)}, #{Math.round(@_b)}, #{@_roundA})"

  toPercentageRgb: ->
    {
      r: "#{Math.round(@bound01(@_r, 255) * 100)}%"
      g: "#{Math.round(@bound01(@_g, 255) * 100)}%"
      b: "#{Math.round(@bound01(@_b, 255) * 100)}%"
      a: @_a
    }

  toPercentageRgbString: ->
    if @_a is 1
      "rgb(#{Math.round(@bound01(@_r, 255) * 100)}%, #{Math.round(@bound01(@_g, 255) * 100)}%, #{Math.round(@bound01(@_b, 255) * 100)}%)"
    else
      "rgba(#{Math.round(@bound01(@_r, 255) * 100)}%, #{Math.round(@bound01(@_g, 255) * 100)}%, #{Math.round(@bound01(@_b, 255) * 100)}%, #{@_roundA})"

  toRatioRgbString: ->
    if @_a is 1
      "rgb(#{Math.round(@bound01(@_r, 255))}, #{Math.round(@bound01(@_g, 255))}, #{Math.round(@bound01(@_b, 255))})"
    else
      "rgba(#{Math.round(@bound01(@_r, 255))}, #{Math.round(@bound01(@_g, 255))}, #{Math.round(@bound01(@_b, 255))}, #{@_roundA})"

  toName: ->
    if @_a is 0
      return 'transparent'
    if @_a < 1
      return false
    @hexNames[@rgbToHex(@_r, @_g, @_b, true)] or false

  toString: (format) ->
    formatSet = !!format
    format = format or @_format
    formattedString = false
    hasAlpha = @_a < 1 and @_a >= 0
    needsAlphaFormat = not formatSet and hasAlpha and (format is 'hex' or format is 'hex6' or format is 'hex3' or format is 'name')
    if needsAlphaFormat
      # Special case for "transparent", all other non-alpha formats
      # will return rgba when there is transparency.
      if format is 'name' and @_a is 0
        return @toName()
      return @toRgbString()
    if format is 'rgb'
      formattedString = @toRgbString()
    if format is 'prgb'
      formattedString = @toPercentageRgbString()
    if format is 'rrgb'
      formattedString = @toRatioRgbString()
    if format is 'hex' or format is 'hex6'
      formattedString = @toHexString()
    if format is 'hex3'
      formattedString = @toHexString(true)
    if format is 'hex8'
      formattedString = @toHex8String()
    if format is 'name'
      formattedString = @toName()
    if format is 'hsl'
      formattedString = @toHslString()
    if format is 'rhsl'
      formattedString = @toRatioHslString()
    if format is 'hsv'
      formattedString = @toHsvString()
    formattedString or @toHexString()

  clone: ->
    TinyColor @toString()

  random: ->
    @fromRatio
      r: Math.random()
      g: Math.random()
      b: Math.random()

  # `equals`
  # Can be called with any TinyColor input
  equals: (color1, color2) ->
    if not color1 or not color2
      return false
    TinyColor(color1).toRgbString() is TinyColor(color2).toRgbString()
