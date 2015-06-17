$(function() {
  var $nav      = $('#main-navigation-container'),
      $trigger  = $('#main-navigation-trigger');

  $trigger.on('touchstart click', function(e) {
    e.preventDefault();

    var $elements = $('body, html').add($nav).add($trigger);

    if ($nav.is('.navigation-active')) {
      $elements.removeClass('navigation-active');
    } else {
      $elements.addClass('navigation-active');
    }
  });

  // Prepends Automatic Translation notice to body
  $("<div class='automatic-translation-notice'>Automatically Translated by Google</div>").prependTo('body');
});
