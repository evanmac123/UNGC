$(function() {
  var $trigger        = $('#section-nav-trigger'),
      $container      = $('#section-nav-container'),
      containerHeight = $container.height(),
      is_open         = true;


  var toggleContainer = function() {
    if (is_open) {
      $container.height(0);
      $trigger.removeClass('is-open');
      is_open = false;
    }
    else {
      $container.height(containerHeight);
      $trigger.addClass('is-open');
      is_open = true;
    }
  };

  var openContainer = function() {
  };

  toggleContainer();

  $container.addClass('is-ready');

  $trigger.on('click.section-nav', toggleContainer);
});
