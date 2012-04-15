(function() {

  jQuery(function() {
    var headHeight, winHeight;
    winHeight = $(window).height();
    headHeight = $("#header").outerHeight();
    return $("#content").css("height", winHeight - headHeight);
  });

}).call(this);
