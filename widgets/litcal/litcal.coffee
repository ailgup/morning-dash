class Dashing.litcal extends Dashing.Widget

	ready: ->
		#@photoElem = $(@node).find('.photo-box')
		photo = @get('saint_image')
		#if photo
		#	@set 'current_photo', photo
		# This is fired when the widget is done being rendered
	onData: (data) ->
		if data.color
			# clear existing "status-*" classes
			$(@get('node')).attr 'class', (i,c) ->
			  c.replace /\bstatus-\S+/g, ''
			# add new class
			$(@get('node')).addClass "status-#{data.color}"
		if data.saint_image
			image_str="url(\'"+@get('saint_image')+"\')"
			$(@node).getElementsByClassName("photo-box").css("background-image", image_str);
			