module.exports =
  {
    preferredFormat:
      title: 'Preferred Color Format'
      description: 'On opening for the first time, the Color Picker uses this format.'
      type: 'string'
      enum: ['rgb', 'hex', 'hsl', 'hsv']
      default: 'hex'
    fallbackAlphaFormat:
      title: 'Fallback Color Format With Alpha Channel'
      description: 'If the current color has an alpha value less than 1, the picker automatically switches to this notation.'
      type: 'string'
      enum: ['rgb', 'hsl', 'hsv']
      default: 'rgb'
    useLastFormat:
      title: 'Use Last Format'
      description: 'Use the format which was selected before closing the dialog.'
      type: 'boolean'
      default: true
    uppercaseHex:
      title: 'Uppercase Hex Values'
      description: 'Sets hex values to upper case.'
      type: 'boolean'
      default: false
    autoShortHex:
      title: 'Auto Short Hex'
      description: 'Automatically shorten hex values if possible.'
      type: 'boolean'
      default: false
    autoColorNames:
      title: 'Auto Color Names'
      description: 'Automatically switch to a color name e.g color name of #f00 is red, so the color will be set as red.'
      type: 'boolean'
      default: false
  }
