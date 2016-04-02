class Dashing.litcal extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered
  onData: (data) ->
	if data.color
     $(@node).css('background-color', '#fff')
  