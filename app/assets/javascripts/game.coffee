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

  enableShowCards = () ->
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    if thisPlayer == currentPlayer
      $('#show-cards-button').removeClass('disabled')
      $('#show-cards-button').click ->
        $.post 'show_cards', {}, (data, status) ->
          return
        return

  $('#sewers-button').click ->
    if !$(this).hasClass("disabled")
      $.post 'final_encounter', {}, (data, status) ->
        return
    return

  enableRollToMove()
  enableShowCards()
