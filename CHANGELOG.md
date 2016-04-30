## 0.8.0
* Patched up keyboard tabbing
* Corrected tree view toggle events to close the picker
* Added gitter and slack
* :tada: Added color picking from screen :tv: the eyedropper tool is here!
* a fix to override the tabbing order within the popUpPalette
* now works without shadowroot

## 0.7.0
* Improved visibility of main Slider
* Fixes to copy/paste
* Accessibility fixes
* Fixed recursive background color [issue#3](https://github.com/puranjayjain/chrome-color-picker/issues/3)
* Fixed issue with toggling tree view, now the picker closes on tree view toggle
* Moved events to core:cancel and core:confirm for better cross platform support
* Added movement using arrow keys for sliders

## 0.6.0
* Added buttons to save the color and cancel to close the dialog the dialog
* Added ability to delete and copy/paste the swatches in custom palettes

## 0.5.2
* Persistent changes to toggle palette on dialog close
* Click outside the dialog to close it
* Resize window to close it

## 0.5.1
* ~~Fixed License file to be displayed on apm~~ - Sorry this [issue](https://github.com/atom/apm/issues/546) is still pending

## 0.5.0
* removed console logs from code
* added linter to better check for errors in code
* added support for RGB and RGBa (% and fractions) e.g. rgb(100%, 0%, 0%), rgb(1, 1, 0) see [link](https://github.com/bgrins/TinyColor#rgb-rgba)
* added support for HSL and HSLa (% and fractions) e.g. hsl(0, 100%, 50%), hsl(0, 1.0, 0.5) see [link](https://github.com/bgrins/TinyColor#hsl-hsla)
* keep the palette closed or open on dialog open setting
* toggle the palette button
* Updated readme typo
* cursor grab and grabbing fixes

## 0.4.2
* Working on `Auto Set Color` config [issue](https://github.com/puranjayjain/chrome-color-picker/blob/master/lib/config.coffee#L13)
* Fixes for aligning the dialog correctly [issue](https://github.com/puranjayjain/chrome-color-picker/issues/2)
* Added back save color and close the dialog commands
* Corrected the ability to edit hex or color names in hex text editor
* Rearranged changelog order to recent to old

## 0.4.1
* Fixes not opening on multiple windows
* Supports opening on any text editor

## 0.4.0
* Working text editing to change colors
* performance fixes
* Fixed error message when trying to open on non text editor windows

## 0.3.0
* Fixed depreciation warning for `pixelRectForScreenRange` issue
* Center triangle on the selection's center

## 0.2.0
* Implemented all settings except Auto Set Color [here](https://github.com/puranjayjain/chrome-color-picker/blob/master/lib/config.coffee)
* Added FAQ section to readme

## 0.1.0 - First Release
* Added the ability to switch between colors and a past color and present color are in circular swatches in the left
* Minor UI tweaks from chrome -> white colored sliders as opposed to black contrasted to be easily visible
* Added color format switching
* Added option to add custom palettes
* Option to scroll on the sliders and the main canvas
