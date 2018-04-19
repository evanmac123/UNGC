$(function() {
  if($("form#new_signing").length < 1) {
    return;
  }

  var $textField = $("input[data-autocomplete]");
  var autocompleteType = $textField.data('autocomplete');
  var $autocompleteTarget = $($textField.data('autocomplete-target'));
  var initiativeId = $textField.data('initiative-id');
  var autocompleteUrl = "/api/v1/autocomplete/" + autocompleteType + ".json?initiative_id=" + initiativeId;

  $textField.autocomplete({
    source: autocompleteUrl,
    select: function(event, ui) {
      $autocompleteTarget.val(ui.item.id);
    }
  });

});
