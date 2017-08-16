$(document).ready ->

  enableRollToMove = () ->
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    if thisPlayer == currentPlayer
      $('#roll-to-move-button').removeClass('disabled')
      $('#roll-to-move-button').click ->
        $.post 'roll_to_move', {}, (data, status) ->
          return
        return

  enableRollToMove()
