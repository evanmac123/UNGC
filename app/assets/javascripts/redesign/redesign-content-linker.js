$(function() {
  var links = $('.main-content-section a');

  var needsRedesign = function(href) {
    return href.match(/^\/redesign\/|^http:/) ? false : true;
  };

  links.each(function(i,e) {
    var $e = $(e);
    var href = $e.attr('href');
    if (needsRedesign(href)) {
      $e.attr('href', '/redesign' + href);
    }
  });
});