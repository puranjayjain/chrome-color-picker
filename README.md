# chrome-color-picker
A color picker inspired by chrome's dev tools color picker (or [spectrum](https://github.com/bgrins/spectrum) color picker)

# Preview


# Features
## Pick Colors in these formats
(Along with their alpha variants except for hex)

- hex
- rgb
- hsl

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

# Powered by
The plugin uses the following projects (or their sources) in some manner:
- [https://github.com/js2coffee/js2coffee](https://github.com/js2coffee/js2coffee) to convert the code
- [https://github.com/bgrins/spectrum](https://github.com/bgrins/spectrum) for the original inspiration
- [https://github.com/auchenberg/chrome-devtools-app](https://github.com/auchenberg/chrome-devtools-app) to understand the working of the devtools
- [https://github.com/bgrins/TinyColor](https://github.com/bgrins/TinyColor) for working with colors
- [https://github.com/desandro/draggabilly](https://github.com/desandro/draggabilly) for sliding across the main canvas

Feel free to use the source code of the converted files as long as you adhere to their respective licenses.

# Customise the key binding to your taste
Open your **keymap** file and add this line to it:
```
'atom-workspace':
  'your-keybinding': 'chrome-color-picker:toggle'
```
**Note: Your-keybinding can be e.g ctrl+shift+c and also make sure to disable the default keybinding from the package's settings**

# Purpose to create
This implementation was built from ground up to:
- Aid web developers to work with colors more easily and in a friendly environment
- To learn about the hsv color model
- Learn more of [coffeescript](http://coffeescript.org/#destructuring)

# License

This project is licensed under an **MIT License**.

The list of all 3rd party licenses along with the main License can be found [here](https://github.com/puranjayjain/chrome-color-picker/blob/master/LICENSE.md)
