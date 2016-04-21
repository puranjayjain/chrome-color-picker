# chrome-color-picker
A color picker inspired by chrome's dev tools color picker (or [spectrum](https://github.com/bgrins/spectrum) color picker)

## Preview
![Demo Image](https://raw.githubusercontent.com/puranjayjain/chrome-color-picker/master/demo.gif)

**Note: The color highlight or marker is not part of this package, to obtain that functionality we use [pigments](https://atom.io/packages/pigments)**

# Simple Usage
- Open the dialog using the shortcut key or using the context menu
- Press Escape to close it.
<br>**or**
- Press Enter to update the color

# Features
## Pick Colors in these formats
* HEX
* RGB
* RGBa
* HSL
* HSLa

## Integrated Palette
- Use the palette with the picker as done in dev tools.
- Contains the [material design palette](https://www.google.com/design/spec/style/color.html) by default.
- Click any palette swatch to select it.
- Double click any material palette swatch to expand it (except black or white swatch).

## Slide using scroll
You can use the mouse wheel to scroll on the sliders and the main canvas to change the values.
You can also do the following:
- Use `ctrl + wheel` to increment more value.
- Use `shift + wheel` to slide from left to right or vice-versa on the main slider (or canvas).
- Similarly Use `ctrl + shift + wheel` to increment more value.

**Note: ctrl also means cmd in unix based operating systems like linux or OS X**

## Supports multiple cursors
When you have multiple cursors it inserts the color in each of their locations

**Note: this feature is still not stable so feel free to point out any issues with it**

# Powered by
The plugin uses the following projects (or their sources) or technologies in some manner:
- [Custom Elements](http://www.html5rocks.com/en/tutorials/webcomponents/customelements)
- [https://github.com/js2coffee/js2coffee](https://github.com/js2coffee/js2coffee) to convert the code
- [https://github.com/bgrins/spectrum](https://github.com/bgrins/spectrum) for the original inspiration
- [https://github.com/auchenberg/chrome-devtools-app](https://github.com/auchenberg/chrome-devtools-app) to understand the working of the devtools
- [https://github.com/bgrins/TinyColor](https://github.com/bgrins/TinyColor) for working with colors
- [https://github.com/desandro/draggabilly](https://github.com/desandro/draggabilly) for sliding across the main canvas

Feel free to use the source code of the converted files as long as you adhere to their respective licenses.

# Customise the key binding to your taste
Open your **keymap** file and add this line to it:
```CoffeeScript
'atom-workspace':
  'your-keybinding': 'chrome-color-picker:toggle'
```
**Note: Your keybinding can be e.g ctrl+alt+c and also make sure to disable the default keybinding from the package's settings or resolve it using the keybinding resolver**

## The commands that are supported currently are:
* chrome-color-picker:toggle - triggers dialog open/close
* chrome-color-picker:close  - triggers dialog close
* chrome-color-picker:save   - triggers the color to be updated back to the editor

## More keys (cannot be modified)
- Press `escape` to close the dialog
- Press `enter` to update the color

# Purpose to create
This implementation was built from ground up to:
- Aid web developers to work with colors more easily and in a friendly environment
- To learn about the hsv color model
- Learn more of [coffeescript](http://coffeescript.org)

# FAQs

1) I am seeing strange settings which I'm not able to edit

**Solution**
  1. Open the developer tools in atom (View > Developers > Toggle Developer Mode or Using `ctrl + alt + i`)

  2. Enter this command in the developer tools console `atom.config.unset('chrome-color-picker')` and restart atom

2) How do I know which settings override which ones?

**Solution**
  - Although there is no guide (yet) for the specificity of settings or which settings are above which ones.
But you can know about some of them [here](https://github.com/puranjayjain/chrome-color-picker/blob/master/lib/modules/core/Input.coffee#L163)

Feel free to update the [wiki](https://github.com/puranjayjain/chrome-color-picker/wiki/Setting's-specificity) with your findings.

3) Do you mind feature requests or suggestions?

**Solution**<br>
They are always welcome, even if they are present in the [milestone](https://github.com/puranjayjain/chrome-color-picker/milestones)

# Versioning

For transparency into our release cycle and in striving to maintain backward
compatibility, Material Design Lite is maintained under
[the Semantic Versioning guidelines](http://semver.org/). Sometimes we screw up,
but we'll adhere to those rules whenever possible.

# License

This project is licensed under an **MIT License**.

The list of all 3rd party licenses along with the main License can be found [here](https://github.com/puranjayjain/chrome-color-picker/blob/master/LICENSE.md)
