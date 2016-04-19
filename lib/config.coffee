module.exports =
  {
    General:
      title: 'General Settings'
      type: 'object'
      properties:
        preferredFormat:
          title: 'Preferred Color Format'
          description: 'On opening for the first time, the Color Picker uses this format.'
          type: 'string'
          enum: ['rgb', 'hex', 'hsl', 'As authored']
          default: 'As authored'
        # TODO implementation
        autoSetColor:
          title: 'Auto Set Color'
          description: 'Automatically set the color values as you edit them'
          type: 'boolean'
          default: false
        # TODO implementation
        autoShortHex:
          title: 'Compressed text colors'
          description: 'Place the color format without any spaces and zeroes (if possible), e.g rgba(0, 0, 0, 0.26) becomes rgba(0,0,0,.26)'
          type: 'boolean'
          default: false
    HexColors:
      title: 'Hex Color Specific Settings'
      type: 'object'
      properties:
        fallbackAlphaFormat:
          title: 'Fallback Color Format With Alpha Channel'
          description: 'If the current color has an **alpha** value less than **1**, the picker automatically switches to this notation.'
          type: 'string'
          enum: ['rgb', 'hsl']
          default: 'rgb'
        # TODO implementation
        uppercaseHex:
          title: 'Uppercase Hex Values'
          description: 'Sets **hex** values to upper case.'
          type: 'boolean'
          default: false
        # TODO implementation
        autoShortHex:
          title: 'Auto Shorten Hex'
          description: 'Automatically shorten **hex** values if possible. e.g color #f00f00 becomes #f00'
          type: 'boolean'
          default: false
        # TODO implementation
        autoColorNames:
          title: 'Auto Color Names'
          description: 'Automatically switch to a color name e.g color name of #f00 is red, so the color will be set as red.'
          type: 'boolean'
          default: false
  }
