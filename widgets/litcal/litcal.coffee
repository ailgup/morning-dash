class Dashing.litcal extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered
  onData: (data) ->
	 if data.color
	   # clear existing "status-*" classes
	   $(@get('node')).attr 'class', (i,c) ->
		 c.replace /\bstatus-\S+/g, ''
	   # add new class
	   $(@get('node')).addClass "status-#{data.color}"
  