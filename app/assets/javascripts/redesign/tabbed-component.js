$(function() {
  var $tabbed           = $('.tabbed-component'),
      $tabs             = $('.tabs .tab button', $tabbed),
      $tabsContents     = $('.tab-content', $tabbed),
      $tabsAndContents  = $tabs.add($tabsContents);

  $tabs.on('click', function(e) {
    e.preventDefault();

    var $tab            = $(this),
        tabContent      = $tab.data('tab-content'),
        $tabContent     = $tabsContents.filter('.' + tabContent),
        $tabAndContent  = $tab.add($tabContent);

    // Add active class to
    $tabAndContent.addClass('active');

    // set url based on tab
    var id = $tab.attr('id');
    if (id) { // only if we have ids on buttons
      // XXX this is here because we want to update the url
      // without moving the page
      if(history.pushState) {
        history.pushState(null, null, '#' + id);
      }
      else {
        location.hash = id;
      }
    }

    // Deactivate tabs and tabsContents which don't match this tab
    $tabsAndContents.not($tabAndContent).removeClass('active');
  });

  // select active tab based on href on load
  var url = window.location.href;
  var seg = url.split('#')[1];
  if (seg) {
    $('#'+seg, $tabbed).click();
  }
});
