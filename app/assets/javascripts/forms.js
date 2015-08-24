$(function() {
  var $checkboxesAndRadios = $('input:checkbox, input:radio');

  $checkboxesAndRadios
    .on('focusin', function(e) {
      var $errorParent = $(this).parent('.field_with_errors');
      if ($errorParent.length) {$errorParent.addClass('focus');}
    })
    .on('focusout', function(e) {
      var $errorParent = $(this).parent('.field_with_errors');
      if ($errorParent.length) {$errorParent.removeClass('focus');}
    })
    .on('change', function(e) {
      var $input = $(this),
          $errorParent = $input.parent('.field_with_errors');

      if ($errorParent.length) {
        if ($input.is(':checked')) {
          $errorParent.addClass('checked');

          if ($input.is(':radio')) {
            $checkboxesAndRadios.filter('[name="' + $input.attr('name') + '"]').not($input).prop('checked', false).change();
          }
        }
        else {
          $errorParent.removeClass('checked');
        }
      }

    });
});
