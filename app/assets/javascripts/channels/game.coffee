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
      disableRollToMove()
      $('#players').html(data.players)
      doMove(data.from_position, data.to_position, data.move_result)

    if data.card?
      if data.encounter?
        $('#encounter').html(data.encounter)
        showEncounter(data.card, data.value, data.resources)
      else
        showCard(data.card)

    if data.encounter_in_progress
      if data.step == "choose_cards" # populate cards; post contains chosen_card and chosen_value
        chooseCards()
      if data.step == "show_card" # populate selected card
        showAllyOrDistraction()
      if data.step == "show_rolls"
        showRolls()
      if data.step == "show_outcome"
        showOutcome()

    if data.cards?
      $('#cards').html(data.cards)
      showCards()

  currentPosition = () ->
    parseInt($('#the-current-player').data("position"))

  thisPlayerIsCurrentPlayer = () ->
    thisPlayer = $('#this-player').data("name")
    currentPlayer = $('#current-player').data("name")
    return thisPlayer == currentPlayer

  enableRollToMove = () ->
    if thisPlayerIsCurrentPlayer == true == true
      $('#roll-to-move-button').removeClass('disabled')
      $('#roll-to-move-button').click ->
        $('#roll-to-move-button').off('click')
        $.post 'roll_to_move', {}, (data, status) ->
          return
        return

  disableRollToMove = () ->
    $('#roll-to-move-button').off('click')
    $('#roll-to-move-button').addClass('disabled')

  enableShowCards = () ->
    if thisPlayerIsCurrentPlayer == true
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
      if thisPlayerIsCurrentPlayer == true
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
    if thisPlayerIsCurrentPlayer == true
      $('#end-turn-button').removeClass('disabled')
      $('#end-turn-button').click ->
        $.post 'end_turn', {}, (data, status) ->
          return
        return

  doMove = (from_position, to_position, result) ->
    $('#dice-result-container').addClass('appear')
    if thisPlayerIsCurrentPlayer == true
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
    setTimeout (->
      $('#drawn-card').removeClass 'appear'
      return
    ), 4000

    $('#encounter').removeClass('n-d')
    $('#encounter').addClass('appear')
    $('#continue-button').click ->
      $.post 'choose_cards', {
        drawn_card: $('#drawn-card').data('value')
      }, (data, status) ->
        return
      return

  chooseCards = () ->
    if thisPlayerIsCurrentPlayer == true
      $('.card').click ->
        $('.card').removeClass('selected')
        $(this).addClass('selected')
        if $(this).data("name") == "ally"
          cardInPlay = "Ally"
          cardInPlayValue = $(this).data("value")
        else
          # diceReduction = $(this).data("value")
          # if difficulty - diceReduction < 1
          #   diceReduction += difficulty - diceReduction - 1
          cardInPlay = "Distraction"
          cardInPlayValue = $(this).data("value")
    $('#continue-button').click ->
      $.post 'show_chosen_card', {
        chosen_card: $('.card.selected').data('name'),
        chosen_value: $('.card.selected').data('value')
      }, (data, status) ->
        return
      return

  showAllyOrDistraction = (card) ->
    $('#chosen-card').html(card)
    $('#chosen-card-container').removeClass('n-d')
    $('#chosen-card-container').addClass('appear')
    $('#continue-button').click ->
      $.post 'show_rolls', {}, (data, status) ->
        return
      return

  showRolls = () ->
    $('#player-roll-container').removeClass('n-d')
    setTimeout (->
      $('#player-roll-container').addClass('appear')
      $('#opponent-roll-container').addClass('appear')
      return
    ), 4000

    $('#opponent-roll-container').removeClass('n-d')
    setTimeout (->
      $('#opponent-roll-container').addClass('appear')
      return
    ), 4000
    $('#continue-button').click ->
      $.post 'show_outcome', {}, (data, status) ->
        return
      return

  showOutcome = () ->
    $('#encounter-outcome-container').removeClass('n-d')
    $('#encounter-outcome-container').addClass('appear')

    if thisPlayerIsCurrentPlayer == true
      $('#outcome-confirm-button').click ->
        enableEndTurn()
        $.post 'end_encounter', {}, (data, status) ->
          return
        return

  rollDice = (quantity) ->
    result = 0
    i = 0
    while i < quantity
      result += Math.floor(Math.random() * 6) + 1
      i++
    return result
