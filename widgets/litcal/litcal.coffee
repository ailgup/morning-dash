class Dashing.litcal extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered
	$(@node).css('background-color',@get('color'))
  onData: (data) ->
	 if data.status
	   # clear existing "status-*" classes
	   $(@get('node')).attr 'class', (i,c) ->
		 c.replace /\bstatus-\S+/g, ''
	   # add new class
	   $(@get('node')).addClass "status-#{data.color}"
  