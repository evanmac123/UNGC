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

    // Deactivate tabs and tabsContents which don't match this tab
    $tabsAndContents.not($tabAndContent).removeClass('active');
  });
});
