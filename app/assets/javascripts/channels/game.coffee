App.game = App.cable.subscriptions.create "GameChannel",

  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    if data.next_turn?
      $('#game').html(data.game)
      enableRollToMove()
    if data.move_result?
      doMove(data.move_result)
    if data.card?
      showCard(data.card)

  enableRollToMove = () ->
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    alert(thisPlayer)
    alert(currentPlayer)
    if thisPlayer == currentPlayer
      $('#roll-to-move-button').removeClass('disabled')
      $('#roll-to-move-button').click ->
        $.post 'roll_to_move', {}, (data, status) ->
          return
        return

  disableRollToMove = () ->
    $('#roll-to-move-button').off('click')
    $('#roll-to-move-button').addClass('disabled')

  enableDrawACard = () ->
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    if thisPlayer == currentPlayer
      $('#draw-a-card-button').removeClass('disabled')
      $('#draw-a-card-button').click ->
        $.post 'draw_card', {}, (data, status) ->
          return
        return

  disableDrawACard = () ->
    $('#draw-a-card-button').off('click')
    $('#draw-a-card-button').addClass('disabled')

  enableEndTurn = () ->
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    if thisPlayer == currentPlayer
      $('#end-turn-button').removeClass('disabled')
      $('#end-turn-button').click ->
        $.post 'end_turn', {}, (data, status) ->
          return
        return

  doMove = (result) ->
    $('#dice-result').addClass('appear')
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    if thisPlayer == currentPlayer
      $('#dice-result').text("You rolled a " + result)
    else
      $('#dice-result').text(currentPlayer + " rolled a " + result)
    current_position = parseInt($('#the-current-player').data("position"))
    new_space = $('#space-' + ((current_position + result) % 32))
    new_position = new_space.offset()
    $('#the-current-player').animate {
      left: new_position.left + Math.floor(Math.random() * 50),
      top: new_position.top + Math.floor(Math.random() * 50)
    }, 1000, ->
      $('#dice-result').removeClass('appear')
      $('#building').css("background-image", "url(/assets/buildings/building_" + (current_position + result) + ".jpg)")
      $('#card-button').removeClass('disabled')
      disableRollToMove()
      enableDrawACard()
      return

  showCard = (card) ->
    $('#drawn-card').addClass('appear')
    $('#drawn-card').css("background-image", "url(/assets/cards/" + card + ".png)")
    disableDrawACard()
    enableEndTurn()
    setTimeout (->
      $('#drawn-card').removeClass 'appear'
      return
    ), 4000
