$(function() {
  var $form = $('#main-search');
  var $inputs = $('#main-search-filters input');

  $inputs.on('change', function(e) {
    var $input = $(this);
    var action = $input.data('action');

    // change the form action
    $form.attr('action', action);

    // update the checked state
    $inputs.attr('checked', function(index, attr) {
      var $input = $($inputs.get(index))
      return $input.data('action') === action;
    });
  });
})
