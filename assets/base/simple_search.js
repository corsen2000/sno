$(function() {
	$.getJSON($("#search_container").data("index"), function(data) {
		$( "#search" ).autocomplete({
			source: data,
			autoFocus: true,
			delay: 0,
			focus: function(event, ui) {				
				if ( /^(key)/.test(event.originalEvent.originalEvent.type) ) {
					$("#search").val(ui.item.display);
				}				
				return false;
			},
			select: function(event, ui) {
				window.location.href = "file://" + ui.item.value;
				return false;
			}
		});
	});
});