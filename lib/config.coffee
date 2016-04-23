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
        autoSetColor:
          title: 'Auto Set Color'
          description: 'Automatically set the color values as you edit them'
          type: 'boolean'
          default: false
        autoShortColor:
          title: 'Compress text colors'
          description: 'Place the color format without any spaces and zeroes (if possible)<br/>*e.g* rgba(0, 0, 0, 0.26) becomes rgba(0,0,0,.26)'
          type: 'boolean'
          default: false
        autoColorNames:
          title: 'Auto Color Names'
          description: 'Automatically switch to a color name<br/>*e.g* color name of #f00 is red, so the color will be set as red.'
          type: 'boolean'
          default: false
        paletteOpen:
          title: 'Palette Open'
          description: 'If the palette is open when the dialog is opened or not.'
          type: 'boolean'
          default: true
        showButtons:
          title: 'Show the bottom buttons'
          description: 'If enabled the dialog will show the ok and cancel buttons.'
          type: 'boolean'
          default: false
    HexColors:
      title: 'Hex Color Specific Settings'
      type: 'object'
      properties:
        fallbackAlphaFormat:
          title: 'Fallback Color Format With Alpha Channel'
          description: 'If the current color has an **alpha** value less than **1**<br/>The picker automatically switches to this notation.'
          type: 'string'
          enum: ['rgb', 'hsl']
          default: 'rgb'
        uppercaseHex:
          title: 'Uppercase Hex Values'
          description: 'Sets **hex** values to UPPER CASE.'
          type: 'boolean'
          default: false
        autoShortHex:
          title: 'Auto Shorten Hex'
          description: 'Automatically shorten **hex** values if possible.<br/>*e.g* color #f00f00 becomes #f00'
          type: 'boolean'
          default: false
        forceHexSize:
          title: 'Force the size of hex string'
          description: 'Force the **hex** to be specific to a certain size if it is possible<br/>*e.g* **hex6** of #f00 is #f00f00'
          type: ['boolean', 'string']
          enum: [false, 'hex3', 'hex6', 'hex8']
          default: false
    RgbColors:
      title: 'RGB and RGBa Color Specific Settings'
      type: 'object'
      properties:
        preferredFormat:
          title: 'Preferred output format'
          description: 'Format in which the rgb or rgba colors (whichever apply) are output to the editor.<br/>[More info](https://github.com/puranjayjain/chrome-color-picker/wiki/RGB-Formats)'
          type: 'string'
          enum: ['standard', 'prgb', 'rrgb']
          default: 'standard'
    HslColors:
      title: 'HSL and HSLa Color Specific Settings'
      type: 'object'
      properties:
        preferredFormat:
          title: 'Preferred output format'
          description: 'Format in which the hsl or hsla colors (whichever apply) are output to the editor.<br/>[More info](https://github.com/puranjayjain/chrome-color-picker/wiki/HSL-Formats)'
          type: 'string'
          enum: ['standard', 'rhsl']
          default: 'standard'
  }
