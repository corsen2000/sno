$(function() {
	$.getJSON($("#search_container").data("index"), function(data) {
		$( "#search" ).autocomplete({
			source: data,
			select: function(event, ui) {
				window.location.href = "file://" + ui.item.value;
			}
		});
	});
});