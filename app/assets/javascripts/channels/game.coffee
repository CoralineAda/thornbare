App.game = App.cable.subscriptions.create "GameChannel",

  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    if data.next_turn?
      $('#game').html(data.game)
      enableRollToMove()
      disableShowCards()
      enableShowCards()

    if data.end_encounter?
      $('#game').html(data.game)

    if data.move_result?
      $('#players').html(data.players)
      doMove(data.from_position, data.to_position, data.move_result)

    if data.card?
      if data.encounter?
        showEncounter(data.card, data.value, data.resources)
      else
        showCard(data.card)

    if data.cards?
      $('#cards').html(data.cards)
      showCards()

  currentPosition = () ->
    parseInt($('#the-current-player').data("position"))

  enableRollToMove = () ->
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    if thisPlayer == currentPlayer
      $('#roll-to-move-button').removeClass('disabled')
      $('#roll-to-move-button').click ->
        $.post 'roll_to_move', {}, (data, status) ->
          return
        return

  disableRollToMove = () ->
    $('#roll-to-move-button').off('click')
    $('#roll-to-move-button').addClass('disabled')

  enableShowCards = () ->
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    if thisPlayer == currentPlayer
      $('#show-cards-button').removeClass('disabled')
      $('#show-cards-button').click ->
        $.post 'show_cards', {}, (data, status) ->
          return
        return

  showCards = () ->
    $('#cards').addClass('appear')
    setTimeout (->
      $('#cards').removeClass 'appear'
      return
    ), 5000

  disableShowCards = () ->
    $('#show-cards-button').off('click')
    $('#show-cards-button').addClass('disabled')

  disableRollToMove = () ->
    $('#roll-to-move-button').off('click')
    $('#roll-to-move-button').addClass('disabled')

  enableDrawACard = () ->
    if currentPosition() % 4 == 0
      thisPlayer = $('#this-player').data("name")
      currentPlayer = $('#current-player').data("name")
      if thisPlayer == currentPlayer
        $('#draw-a-card-button').removeClass('disabled')
        $('#draw-a-card-button').click ->
          $.post 'draw_card', {}, (data, status) ->
            return
          return
    else
      enableEndTurn()

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

  doMove = (from_position, to_position, result) ->
    $('#dice-result-container').addClass('appear')
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    if thisPlayer == currentPlayer
      $('#dice-result-container').text("You rolled a " + result)
    else
      $('#dice-result-container').text(currentPlayer + " rolled a " + result)
    new_space = $('#space-' + to_position)
    new_position = new_space.offset()
    $('#current-player-token').animate {
      left: new_position.left + Math.floor(Math.random() * 50),
      top: new_position.top + Math.floor(Math.random() * 50)
    }, 1000, ->
      $('#dice-result-container').removeClass('appear')
      $('#building').css("background-image", "url(/assets/buildings/building_" + to_position + ".jpg)")
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

  showEncounter = (card, difficulty) ->
    $('#drawn-card').addClass('appear')
    $('#drawn-card').css("background-image", "url(/assets/cards/" + card + ".png)")
    disableDrawACard()
    enableEndTurn()
    setTimeout (->
      $('#drawn-card').removeClass 'appear'
      return
    ), 4000

    $('#encounter').removeClass('n-d')
    $('#encounter').addClass('appear')

    additionalDice = 0
    diceReduction = 0
    cardInPlay = ""
    cardInPlayValue = 0
    cardsLost = []
    resourcesLostValue = 0
    success = true

    $('#player-roll-confirm-button').click ->
      $('#player-roll-container').addClass('n-d')
      $('#opponent-roll-container').removeClass('n-d')
      $('#opponent-roll-container').addClass('appear')
    $('#opponent-roll-confirm-button').click ->
      $('#opponent-roll-container').addClass('n-d')
      $('#encounter-outcome-container').removeClass('n-d')
      $('#encounter-outcome-container').addClass('appear')

    $('.card').click ->
      $('.card').removeClass('selected')
      $(this).addClass('selected')
      if $(this).data.name == "ally"
        additionalDice = $(this).data.value
        cardInPlay = "Ally"
        cardInPlayValue = $(this).data.value
      else
        diceReduction = $(this).data.value
        if difficulty - diceReduction < 1
          diceReduction += difficulty - diceReduction - 1
        cardInPlay = "Distraction"
        cardInPlayValue = $(this).data.value

    $('#roll-for-encounter').click ->
      $('#encounter').addClass('n-d')
      $('#player-roll-container').removeClass('n-d')
      $('#player-roll-container').addClass('appear')
      playerResult = rollDice(1 + additionalDice)
      opponentResult = rollDice(difficulty - diceReduction)
      $('#player-roll-value').html(playerResult)
      $('#opponent-roll-value').html(opponentResult)
      if playerResult == opponentResult
        $('#outcome').html("It's a draw!")
      if playerResult > opponentResult
        $('#outcome').html("You have prevailed!")
      if playerResult < opponentResult
        success = false
        $('#outcome').html("You fought bravely but were overcome... You have lost " + difficulty + " resources.")

  $('#outcome-confirm-button').click ->
    alert('ok')
    # $.post 'end_encounter', {
    #     success: success
    #     card_spent: { name: cardInPlay, value: cardInPlayValue },
    #     resources_lost: resourcesLostValue
    #   }, (data, status) ->
    #   return
    # return

  rollDice = (quantity) ->
    result = 0
    i = 0
    while i < quantity
      result += Math.floor(Math.random() * 6) + 1
      i++
    return result
