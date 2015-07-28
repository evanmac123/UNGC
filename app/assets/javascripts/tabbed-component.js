$(function() {
  var $tabbed           = $('.tabbed-component');

  // Only run if page has at least 1 tabbed component
  if ($tabbed.length <= 0) {return;}

  var $tabs             = $('.tabs .tab button', $tabbed);
  var $tabsContents     = $('.tab-content', $tabbed);
  var $tabsAndContents  = $tabs.add($tabsContents);
  var hasNavigation     = !!$tabbed.data('has-navigation');

  $tabs.on('click', function(e) {
    e.preventDefault();

    var $tab            = $(this);
    var tabContent      = $tab.data('tab-content');
    var $tabContent     = $tabsContents.filter('.' + tabContent);
    var $tabAndContent  = $tab.add($tabContent);

    // Add active class to
    $tabAndContent.addClass('active');

    // set url based on tab
    if (hasNavigation) { // only if we have ids on buttons
      // XXX this is here because we want to update the url
      // without moving the page
      if(history.pushState) {
        history.pushState(null, null, '#' + tabContent);
      }
      else {
        location.hash = tabContent;
      }
    }

    // Deactivate tabs and tabsContents which don't match this tab
    $tabsAndContents.not($tabAndContent).removeClass('active');
  });

  // select active tab based on href on load
  var url = window.location.href;
  var seg = url.split('#')[1];
  if (seg) {
    $('.tab-'+seg, $tabbed).click();
  }
});
