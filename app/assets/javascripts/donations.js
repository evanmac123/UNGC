$(function() {

  var $form = $('#new_donation');
  var $submitButton = $form.find('.submit');
  var submitText = $submitButton.val();

  function stripeResponseHandler(status, response) {
    if(response.error) {
      // show the error message
      $form.find('.payment-errors').text(response.error.message);

      // clear previous errors
      $(".field_with_errors > *[data-stripe]").unwrap();

      // highlight error fields
      var param = response.error.param;
      if(param) {
        var $fieldWithErrors = $("input[data-stripe=\"" + param + "\"]");
        $fieldWithErrors.wrap("<div class='field_with_errors'></div>");
      }

      // re-enable the submit button
      $submitButton.prop('disabled', false);
      $submitButton.val(submitText);
    } else {
      // default credit card type if it hasn't already been selected
      var $cardType = $("#donation_credit_card_type");
      if(!$cardType.val()) {
        $cardType.val(response.card.brand);
      }

      var token = response.id;

      $form.append($('<input type="hidden" name="donation[token]">').val(token));

      $form.addClass("submitted");
      $form.get(0).submit();
    }
  }

  $form.submit(function(event) {
    // Disable the submit button to prevent repeated clicks:
    $submitButton.prop('disabled', true);
    $submitButton.val('Authorizing...');

    // Request a token from Stripe:
    Stripe.card.createToken($form, stripeResponseHandler);

    // Prevent the form from being submitted:
    return false;
  });

  var $companyName = $("input[data-autocomplete]");
  var $organizationId = $("input[name='donation[organization_id]']");

  if($companyName.length > 0 && $organizationId.length > 0) {
    var autocompleteField = $companyName.data('autocomplete');
    var autocompleteUrl = "/api/v1/autocomplete/" + autocompleteField + ".json";

    $companyName.autocomplete({
      source: autocompleteUrl,
      select: function(event, ui) {
        var organizationId = ui.item.id;
        $organizationId.val(organizationId);
      }
    });
  }

  $("#donation_amount").priceFormat({
    prefix: "$",
    centsLimit: 2,
    clearOnEmpty: true
  });

});
