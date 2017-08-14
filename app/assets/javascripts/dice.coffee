$(document).ready ->

  roll = ->
    $('.dice-result').addClass('appear')
    result = Math.floor(Math.random() * 6) + 1
    $('.dice-result').text("You rolled a " + result)
    current_position = parseInt($('#current-player').data("position"))
    new_space = $('#space-' + (current_position + result))
    new_position = new_space.offset()
    $('#current-player').animate {
      left: new_position.left + Math.floor(Math.random() * 50),
      top: new_position.top + Math.floor(Math.random() * 50)
    }, 1000, ->
      return



  $('.dice-button').click ->
    roll()
