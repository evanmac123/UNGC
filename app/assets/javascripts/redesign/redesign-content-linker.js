// this will be removed when we deploy the redesign version of the website
$(function() {
  var links = $('.main-content-section a');

  var needsRedesign = function(href) {
    if (href) {
      return href.match(/^\/redesign|^http(s?):|^mailto:|^#/) ? false : true;
    }
    return false;
  };

  links.each(function(i,e) {
    var $e = $(e);
    var href = $e.attr('href');
    if (needsRedesign(href)) {
      $e.attr('href', '/redesign' + href);
    }
  });
});
