# all the helper functions and prototypes are bundled here
module.exports =
class Helper
  String::isRegistered = ->
    document.createElement(this).constructor != HTMLElement
