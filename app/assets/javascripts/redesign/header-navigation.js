$(function() {
  var $nav      = $('#main-navigation-container'),
      $trigger  = $nav.siblings('.mobile-nav-trigger');

  $trigger.on('touchstart click', function(e) {
    e.preventDefault();
    $nav.add($trigger).toggleClass('active');
  });
});
