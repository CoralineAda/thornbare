$(document).ready ->

  enableRollToMove = () ->
    $('#roll-to-move-button').removeClass('disabled')
    $('#roll-to-move-button').click ->
      $.post 'roll_to_move', {}, (data, status) ->
        return
      return
  disableDrawACard = () ->
    $('#draw-a-card-button').off('click')
    $('#draw-a-card-button').addClass('disabled')

  enableRollToMove()
  disableDrawACard()
