# chrome-color-picker
A color picker inspired by chrome's dev tools color picker (or [spectrum](https://github.com/bgrins/spectrum) color picker)

[![Join us on the Atom Community on Slack](http://atom-slack.herokuapp.com/badge.svg)](http://atom-slack.herokuapp.com/) [![Gitter](https://badges.gitter.im/puranjayjain/chrome-color-picker.svg)](https://gitter.im/puranjayjain/chrome-color-picker?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

**Always mention the relevant person with @username**

## Preview
![Demo Image](https://raw.githubusercontent.com/puranjayjain/chrome-color-picker/master/demo.gif)

**Note: The color highlight or marker is not part of this package, to obtain that functionality we use [pigments](https://atom.io/packages/pigments) and the syntax theme is [chrome-dark-syntax](https://atom.io/packages/chrome-dark-syntax)**

# Install
## Using `apm`:

```
apm install chrome-color-picker
```
## Using Atom
Search for `chrome color picker` in Atom Settings (`Settings > Install > Search`).

# Simple Usage
- Open the dialog using the shortcut key or using the context menu
- Press Escape to close it.
<br>**or**
- Press Enter to update the color

# Features
## Use Colors in these formats
* HEX
* Named ([Web colors](https://en.wikipedia.org/wiki/Web_colors#X11_color_names))
* RGB
* RGBa
* RGB and RGBa %
* RGB and RGBa ratios
* HSL
* HSLa
* HSL and HSLa ratios

## Integrated Palette
- Use the palette with the picker as done in dev tools.
- Contains the [material design palette](https://www.google.com/design/spec/style/color.html) by default.
- Click any palette swatch to select it.
- Double click any material palette swatch to expand it (except black or white swatch).

## Accessibility
You can use the entire picker using just the keyboard.<br>
Use these keys for navigating within the component:
* `Escape`: To close the picker
* `Escape`: To save the value to the editor
* `Tab`: To move to the next part where action can be performed (e.g. button, slider, etc.)
* `Shift + Tab`: To move to the previous part where action can be performed (e.g. button, slider, etc.)
* `Space`: Do the action

There are more actions that are possible with keys and mouse

### Slide using scroll
You can use the mouse wheel to scroll on the sliders and the main canvas to change the values.
You can also do the following:
- Use `ctrl + wheel` to increment more value.
- Use `shift + wheel` to slide from left to right or vice-versa on the main slider (or canvas).
- Similarly Use `ctrl + shift + wheel` to increment more value.

**Note: ctrl also means cmd in Unix based operating systems like Linux or OS X**

### Slide using arrow keys
You can use the arrow keys to scroll on the sliders and the main canvas to change the values.
You can also do the following:
- Use `ctrl + arrowKey` to increment more value.
- All four arrow keys are usable on the main slider.
- Only Right and Left Arrow keys are usable on the slider hue and alpha.

## Supports multiple cursors [Beta]
When you have multiple cursors it inserts the color in each of their locations

## Color Picking from screen [Beta]
You can now pick colors from anywhere on the screen

**Note: Features marked [Beta] are not stable and might not work as expected so feel free to point out any issues with them**

# Powered by
The plugin uses the following projects (or their sources) or technologies in some manner:
- [Custom Elements](http://www.html5rocks.com/en/tutorials/webcomponents/customelements)
- [https://github.com/js2coffee/js2coffee](https://github.com/js2coffee/js2coffee) to convert the code
- [https://github.com/bgrins/spectrum](https://github.com/bgrins/spectrum) for the original inspiration
- [https://github.com/auchenberg/chrome-devtools-app](https://github.com/auchenberg/chrome-devtools-app) to understand the working of the devtools
- [https://github.com/bgrins/TinyColor](https://github.com/bgrins/TinyColor) for working with colors
- [https://github.com/desandro/draggabilly](https://github.com/desandro/draggabilly) for sliding across the main canvas
- [https://github.com/davidtheclark/focus-trap](https://github.com/davidtheclark/focus-trap)
- [https://github.com/davidtheclark/tabbable](https://github.com/davidtheclark/tabbable)
- [https://github.com/niklasvh/html2canvas](https://github.com/niklasvh/html2canvas)

Feel free to use the source code of the converted files as long as you adhere to their respective licenses.

# Customize the key binding to your taste
Open your [keymap](http://flight-manual.atom.io/behind-atom/sections/keymaps-in-depth/) file and add this line to it:
```CoffeeScript
'atom-workspace':
  'your-keybinding': 'chrome-color-picker:toggle'
```
**Note: Your key binding can be e.g. `alt + ctrl + c` and also make sure to disable the default key binding from the package's settings or resolve it using the key binding resolver**

## The commands that are supported currently are:
* chrome-color-picker:toggle        - triggers dialog open/close
* chrome-color-picker:close         - triggers dialog close
* chrome-color-picker:save          - triggers the color to be updated back to the editor
* chrome-color-picker:saveAndClose  - triggers the color to be updated back to the editor and closed after that
* chrome-color-picker:pickcolor     - toggle the color picker eyedropper tool to pick colors from screen

# Purpose to create
This implementation was built from ground up to:
- Aid web developers to work with colors more easily and in a friendly environment
- To learn about the hsv color model
- Learn more of [coffeescript](http://coffeescript.org)

# FAQs

#### 1) I am seeing strange settings which I'm not able to edit

**Solution**
  1. Open the developer tools in atom (View > Developers > Toggle Developer Mode or Using `ctrl + alt + i`)

  2. Enter this command in the developer tools console `atom.config.unset('chrome-color-picker')` and restart atom

#### 2) How do I know which settings override which ones?

**Solution**
  - Although there is no guide (yet) for the specificity of settings or which settings are above which ones.
But you can know about some of them [here](https://github.com/puranjayjain/chrome-color-picker/blob/master/lib/modules/core/Input.coffee#L163)

Feel free to update the [wiki](https://github.com/puranjayjain/chrome-color-picker/wiki/Setting's-specificity) with your findings.

#### 3) Do you mind feature requests or suggestions?

**Solution**<br><br>
They are always welcome, even if they are present in the [milestone](https://github.com/puranjayjain/chrome-color-picker/milestones)

#### 4) Help! the picker won't open !

**Solution**<br><br>
Try restarting atom or closing and opening atom or reloading atom (`View > Developer > Reload Window`)

# Versioning

For transparency into our release cycle and in striving to maintain backward compatibility, package is maintained under [the Semantic Versioning guidelines](http://semver.org/). Sometimes we screw up, but we'll adhere to those rules whenever possible.

# License

Copyright (c) 2016 Puranjay Jain and [Contributors](https://github.com/puranjayjain/chrome-color-picker/graphs/contributors) All Rights Reserved.
This project is licensed under an [MIT License](https://github.com/puranjayjain/chrome-color-picker/blob/master/LICENSE.md).

The list of all 3rd party licenses along with the main License can be found [here](https://github.com/puranjayjain/chrome-color-picker/blob/master/LICENSE.md)
