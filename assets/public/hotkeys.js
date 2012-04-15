(function() {

  jQuery(function() {
    return $(document).bind('keypress', 's', function() {
      window.scrollTo(0, 0);
      $("#search").focus();
      return false;
    });
  });

}).call(this);
