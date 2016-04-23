# the bottom buttons are ok and cancel buttons shown on the bottom of the dialog
helper = require '../helper/helper'

module.exports =
class BottomButtons extends helper
  open: false

  constructor: (addTo) ->
    # create a custom element for the floating panel
    @ok = document.createElement 'BUTTON'
    @cancel = document.createElement 'BUTTON'
    @ok.classList.add 'btn', 'btn-success', 'btn-sm'
    @cancel.classList.add 'btn', 'btn-error', 'btn-sm'
    @ok.innerHTML = 'OK'
    @cancel.innerHTML = 'CANCEL'
    addTo.appendChild @cancel
    addTo.appendChild @ok
