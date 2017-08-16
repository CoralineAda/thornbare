App.game = App.cable.subscriptions.create "GameChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    $('document.body').html(data.game)
    if data.move_result?
      doMove(data.move_result)

  doMove = (result) ->
    $('#dice-result').addClass('appear')
    $('#dice-result').text("You rolled a " + result)
    current_position = parseInt($('#current-player').data("position"))
    new_space = $('#space-' + (current_position + result))
    new_position = new_space.offset()
    $('#current-player').animate {
      left: new_position.left + Math.floor(Math.random() * 50),
      top: new_position.top + Math.floor(Math.random() * 50)
    }, 1000, ->
      $('#dice-result').removeClass('appear')
      $('#building').css("background-image", "url(/assets/buildings/building_" + (current_position + result) + ".jpg)")
      $('#card-button').removeClass('disabled')
      disableRollToMove()
      enableDrawACard()
      return
