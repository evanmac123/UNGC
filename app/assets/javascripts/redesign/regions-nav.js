$(function() {
  var $regionsNav = $("#regions-nav");
  if ($regionsNav.length < 1) {return;}

  // Cache relevant elements
  var $triggers = $regionsNav.find('.region-nav-trigger'),
      $navs     = $regionsNav.find('.regions-nav-region');

  // Cache associated filter list as data attribute of trigger
  $triggers.each(function(){
    var $trigger = $(this);
    $trigger.data('$nav', $navs.filter(function(){
      return $(this).data('region') === $trigger.data('region');
    }));
  });

  // Toggle filter lists on click
  $triggers.on('click', function(event) {
    event.preventDefault();
    var $trigger  = $(event.currentTarget),
        $nav      = $trigger.data('$nav');
    $navs.add($triggers).not([event.currentTarget, $nav.get(0)]).removeClass('is-open');
    $trigger.add($nav).toggleClass('is-open');
  });
});
