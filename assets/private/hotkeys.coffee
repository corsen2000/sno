jQuery ->
	$(document).bind 'keypress', 's', ->
		window.scrollTo(0,0)
		$("#search").focus()
		false