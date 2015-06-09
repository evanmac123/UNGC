$(function() {
  var $nav      = $('#main-navigation-container'),
      $trigger  = $('#main-navigation-trigger');

  $trigger.on('touchstart click', function(e) {
    e.preventDefault();
    $('body').toggleClass('navigation-active');
    $nav.add($trigger).toggleClass('active');
  });
});
