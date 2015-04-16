$(function() {
  var $principles = $('.component-tied-principle'),
      timer       = null;

  $principles.hover(function(e) {
    clearTimeout(timer);
    $principles.removeClass('is-active');
    $(e.currentTarget).addClass('is-active');
  },
  function(e) {
    timer = setTimeout(function() {
      $(e.currentTarget).removeClass('is-active');
    }, 500);
  });
});
