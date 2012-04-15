jQuery ->
	winHeight = $(window).height();
	fromTop = $("#content").position().top;
	contentOffset = parseInt($("#content").css("padding-top")) + parseInt($("#content").css("padding-bottom"))
	pageOffset = parseInt($("#page_content").css("padding-top")) + parseInt($("#page_content").css("padding-bottom"))
	$("#page_content").css("min-height", winHeight - fromTop - contentOffset - pageOffset);