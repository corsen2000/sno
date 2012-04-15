(function() {

  jQuery(function() {
    var contentOffset, fromTop, pageOffset, winHeight;
    winHeight = $(window).height();
    fromTop = $("#content").position().top;
    contentOffset = parseInt($("#content").css("padding-top")) + parseInt($("#content").css("padding-bottom"));
    pageOffset = parseInt($("#page_content").css("padding-top")) + parseInt($("#page_content").css("padding-bottom"));
    return $("#page_content").css("min-height", winHeight - fromTop - contentOffset - pageOffset);
  });

}).call(this);
