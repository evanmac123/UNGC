$(function() {
  var $regionsNav = $("#regions-nav");
  if ($regionsNav.length < 1) {return;}

  // Cache relevant elements
  var $triggers           = $regionsNav.find('.region-nav-trigger'),
      $triggerContainers  = $triggers.parent(),
      $navs               = $regionsNav.find('.regions-nav-region');

  // Cache associated filter list as data attribute of trigger
  $triggers.each(function(){
    var $trigger = $(this);
    $trigger.data('$nav', $navs.filter(function(){
      return $(this).data('region') === $trigger.data('region');
    }));
  });

  // Toggle filter lists on click
  $triggers.on('click', function(event) {
    if ($(window).width() <= 720) {return true;}
    event.preventDefault();
    var $trigger          = $(event.currentTarget),
        $triggerContainer = $trigger.parent(),
        $nav              = $trigger.data('$nav');
    $navs.not($nav).add($triggerContainers.not($triggerContainer)).removeClass('is-open');
    $nav.add($triggerContainer).toggleClass('is-open');
  });
});
