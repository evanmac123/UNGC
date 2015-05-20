$(function() {
  $('body').on('change','select.autolink', function(e) {
    var select = $(e.target);
    var go = select.val();
    var anchor = window.location.hash;
    if (go !== '') {
      window.location = go.replace(/\&amp;/, '&') + anchor;
    }
  });

  if ($('table.sortable').size() > 0) {
    $('table.sortable').tablesorter({widgets: ['zebra']});
  }
});
