App.game = App.cable.subscriptions.create "GameChannel",

  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    if data.next_turn?
      $('#game').html(data.game)
      disableRollToMove()
      enableRollToMove()
      disableShowCards()
      enableShowCards()

    if data.round > 1
      enableEnterSewers()

    if data.can_draw_card?
      enableTradeCards()

    if data.can_trade_card?
      enableDrawACard()

    if data.end_game?
      $('#the-end').html(data.game)
      $('#the-end').removeClass('n-d')
      $('#the-end').addClass('appear')

    if data.trading_cards?
      $("#trade-cards").html(data.game)
      $('#trade-cards').removeClass('n-d')
      $('#trade-cards').addClass('appear')
      if data.trading_partner?
        showSelectTradingCard(data.trading_partner)
      else
        showSelectTradingParner()

    if data.traded_cards?
      $("#trade-cards").html(data.game)
      $('#trade-cards').removeClass('n-d')
      $('#trade-cards').addClass('appear')
      showTradedCards()

    if data.trade_cards_complete?
      $('#trade-cards').addClass('n-d')

    if data.reset?
      $('#game').html(data.game)
      enableShowCards()
      enableEndTurn()

    if data.end_encounter?
      $('#game').html(data.game)

    if data.can_trade_cards == true
      enableTradeCards()

    if data.move_result?
      disableRollToMove()
      $('#players').html(data.players)
      doMove(data.from_position, data.to_position, data.move_result)

    if data.card?
      if data.encounter?
        $('#game').html(data.game)
        showCard(data.card, data.card_type)
        setTimeout (->
          $('#drawn-card').removeClass 'appear'
          return
        ), 4000
        setTimeout (->
          $.post data.next_step, {}, (data, status) ->
            return
          return
        ), 2000
      else
        showCard(data.card, data.card_type)

    if data.encounter_in_progress
      if data.step == "choose_card"
        $('#cards').removeClass('n-d')
        $('#cards').addClass('appear')
        $('#cards').html(data.encounter)
        chooseCards()
      if data.step == "show_ally_or_distraction"
        $('#cards').addClass('n-d')
        $('#encounter').html(data.encounter)
        $('#encounter').removeClass('n-d')
        $('#encounter').addClass('appear')
        showAllyOrDistraction()
      if data.step == "show_rolls"
        $('#encounter').html(data.encounter)
        $('#encounter').removeClass('n-d')
        $('#encounter').addClass('appear')
        showRolls(data.outcome)
      if data.step == "show_outcome"
        $('#encounter').html(data.encounter)
        $('#encounter').removeClass('n-d')
        $('#encounter').addClass('appear')
        showOutcome()
        enableEndTurn()

    if data.cards?
      $('#cards').html(data.cards)
      showCards()

  currentPosition = () ->
    parseInt($('#the-current-player').data("position"))

  thisPlayerIsCurrentPlayer = () ->
    thisPlayer = $('#this-player').data("name")
    return thisPlayer == currentPlayer()

  currentPlayer = () ->
    return $('#current-player').data("name")

  enableEnterSewers = () ->
    if thisPlayerIsCurrentPlayer() == true
      $('#sewers-button').removeClass('disabled')
      $('#sewers-button').click ->
        $.post 'final_encounter', {}, (data, status) ->
          return
        return

  enableTradeCards = () ->
    $('#trade-button').removeClass('disabled')
    $('#trade-button').click ->
      $.post 'select_trading_partner', {}, (data, status) ->
        return
      return

  enableRollToMove = () ->
    if thisPlayerIsCurrentPlayer() == true
      $('#roll-to-move-button').removeClass('disabled')
      $('#roll-to-move-button').click ->
        $('#roll-to-move-button').off('click')
        $('#roll-to-move-button').addClass('disabled')
        $.post 'roll_to_move', {}, (data, status) ->
          return
        return

  disableRollToMove = () ->
    $('#roll-to-move-button').off('click')
    $('#roll-to-move-button').addClass('disabled')

  enableShowCards = () ->
    if thisPlayerIsCurrentPlayer() == true
      $('#show-cards-button').removeClass('disabled')
      $('#show-cards-button').click ->
        $.post 'show_cards', {}, (data, status) ->
          return
        return

  showCards = () ->
    if thisPlayerIsCurrentPlayer() == true
      $('#cards').removeClass('n-d')
      $('#cards').addClass('appear')
      setTimeout (->
        $('#cards').removeClass 'appear'
        $('#cards').addClass('n-d')
        return
      ), 5000

  disableShowCards = () ->
    $('#show-cards-button').off('click')
    $('#show-cards-button').addClass('disabled')

  disableRollToMove = () ->
    $('#roll-to-move-button').off('click')
    $('#roll-to-move-button').addClass('disabled')

  enableDrawACard = () ->
    if thisPlayerIsCurrentPlayer() == true
      $('#draw-a-card-button').removeClass('disabled')
      $('#draw-a-card-button').click ->
        $.post 'draw_card', {}, (data, status) ->
          return
        return

  disableDrawACard = () ->
    $('#draw-a-card-button').off('click')
    $('#draw-a-card-button').addClass('disabled')

  enableEndTurn = () ->
    if thisPlayerIsCurrentPlayer() == true
      $('#end-turn-button').removeClass('disabled')
      $('#end-turn-button').click ->
        $('#end-turn-button').addClass('disabled')
        $.post 'end_turn', {}, (data, status) ->
          return
        return

  doMove = (from_position, to_position, result) ->
    $('#dice-result-container').addClass('appear')
    if thisPlayerIsCurrentPlayer() == true
      $('#dice-result-container').text("You rolled a " + result)
    else
      $('#dice-result-container').text(currentPlayer() + " rolled a " + result)
    new_space = $('#space-' + to_position)
    new_position = new_space.offset()
    $('#current-player-token').animate {
      left: new_position.left + Math.floor(Math.random() * 50),
      top: new_position.top + Math.floor(Math.random() * 50)
    }, 1000, ->
      $('#dice-result-container').removeClass('appear')
      $('#building').css("background-image", "url(/assets/buildings/building_" + (to_position % 32) + ".jpg)")
      $('#card-button').removeClass('disabled')
      disableRollToMove()
      enableDrawACard()
      if thisPlayerIsCurrentPlayer() == true
        if from_position + result >= 32
          alert("You picked up an additional resource from The Bottoms.")
      return

  showCard = (card, cardType) ->
    $('#drawn-card').removeClass('n-d')
    $('#drawn-card').addClass('appear')
    $('#drawn-card').css("background-image", "url(/assets/cards/" + card + ".png)")
    disableDrawACard()
    if cardType != "encounter"
      enableEndTurn()
    setTimeout (->
      $('#drawn-card').removeClass 'appear'
      return
    ), 4000

  showSelectTradingParner = () ->
    $('#trade_cards').removeClass('n-d')
    $('#trade_cards').addClass('appear')
    if thisPlayerIsCurrentPlayer() == true
      $("#trade-select-player-button").click ->
        $.post 'select_cards_to_trade', {
          trading_partner: $('#trade_player option:selected').text()
        }, (data, status) ->
          return
        return
      $("#select-player-to-trade-cancel-button").click ->
        $.post 'cancel_trade_cards', {}, (data, status) ->
          return
        return
    else
      $("#trade-select-player-button").addClass("disabled")
      $("#select-player-to-trade-cancel-button").addClass("disabled")

  showSelectTradingCard = (trading_partner) ->
    $('#trade_cards').removeClass('n-d')
    $('#trade_cards').addClass('appear')
    if thisPlayerIsCurrentPlayer() == true
      $('.card').click ->
        $('.card').removeClass('selected')
        $(this).addClass('selected')
      $("#give-card-button").click ->
        $.post 'do_trade_cards', {
          trading_partner: trading_partner,
          chosen_card: $('.card.selected').data('name'),
          chosen_value: $('.card.selected').data('value')
        }, (data, status) ->
          return
        return
      $("#trade-cancel-button").click ->
        $.post 'cancel_trade_cards', {}, (data, status) ->
          return
        return
    else
      $("#give-card-button").addClass("disabled")
      $("#trade-cancel-button").addClass("disabled")

  showTradedCards = () ->
    if thisPlayerIsCurrentPlayer() == true
      $('#end-trade-button').click ->
        $.post 'cancel_trade_cards', {}, (data, status) ->
          return
        return
    else
      $('#end-trade-button').addClass('disabled')

  showEncounter = (card, difficulty) ->
    disableDrawACard()
    $('#encounter').removeClass('n-d')
    $('#encounter').addClass('appear')
    $('#continue-button').click ->
      $.post 'choose_card', {
        drawn_card: $('#drawn-card').data('value')
      }, (data, status) ->
        return
      return

  chooseCards = () ->
    $('#cards').removeClass('n-d')
    $('#cards').addClass('appear')
    if thisPlayerIsCurrentPlayer() == true
      $('.card').click ->
        $('.card').removeClass('selected')
        $(this).addClass('selected')

    if thisPlayerIsCurrentPlayer() == true
      $('#continue-button').click ->
        $.post 'show_ally_or_distraction', {
          chosen_card: $('.card.selected').data('name'),
          chosen_value: $('.card.selected').data('value')
        }, (data, status) ->
          return
        return
    else
      $('#continue-button').addClass('disabled')

  showAllyOrDistraction = () ->
    $('#chosen-card-container').removeClass('n-d')
    $('#chosen-card-container').addClass('appear')
    if thisPlayerIsCurrentPlayer() == true
      $('#roll-dice').click ->
        $.post 'show_rolls', {}, (data, status) ->
          return
        return
    else
      $('#continue-button').addClass('disabled')

  showRolls = (outcome) ->
    $('#player-roll-container').removeClass('n-d')
    $('#player-roll-container').addClass('appear')
    $('#opponent-roll-container').removeClass('n-d')
    setTimeout (->
      $('#opponent-roll-container').addClass('appear')
      $('#player-roll-container').removeClass('appear')
      return
    ), 2000
    $('#show-result-button').click ->
      $.post 'show_outcome', { outcome: outcome }, (data, status) ->
        return
      return

  showOutcome = () ->
    $('#encounter-outcome-container').removeClass('n-d')
    $('#encounter-outcome-container').addClass('appear')

    if thisPlayerIsCurrentPlayer() == true
      $('#outcome-confirm-button').click ->
        enableEndTurn()
        $.post 'end_encounter', {}, (data, status) ->
          return
        return
      $('#failure-confirm-button').click ->
        $.post 'end_turn', {}, (data, status) ->
          return
        return
      $('#victory-confirm-button').click ->
        $.post 'end_turn', {}, (data, status) ->
          return
        return

  rollDice = (quantity) ->
    result = 0
    i = 0
    while i < quantity
      result += Math.floor(Math.random() * 6) + 1
      i++
    return result

  $('sewers-button').click ->
    $.post 'final_encounter', {}, (data, status) ->
      return
    return
