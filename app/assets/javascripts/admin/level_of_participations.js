$(function() {
  if($("#new_level_of_participation").length < 1) {
    return;
  }

  var $isSubsidiary = $('input[name="level_of_participation[is_subsidiary]"]');
  var $parentCompanyField = $('#select-parent-company');
  var $parentCompanyId = $('#level_of_participation_parent_company_id');
  var $parentCompanyName = $("input[data-autocomplete]");
  var $autocompleteField = $parentCompanyName.data('autocomplete');
  var autocompleteUrl = "/api/v1/autocomplete/" + $autocompleteField + ".json";
  var $invoiceDate = $('#select-invoice-date');
  var $levelOfParticipation = $('input[name="level_of_participation[level_of_participation]"]');

  var onSubsidiaryValueChanged = function(e) {
    $parentCompanyField.toggle(this.value === "true");
  };

  $isSubsidiary.on('change', onSubsidiaryValueChanged);

  onSubsidiaryValueChanged();

  $parentCompanyName.autocomplete({
    source: autocompleteUrl,
    select: function(event, ui) {
      $parentCompanyId.val(ui.item.id);
    }
  });

  var $revenue = $("#level_of_participation_annual_revenue");
  $revenue.priceFormat({
    prefix: "$",
    centsLimit: 0,
    clearOnEmpty: true
  });

  $('input[type=radio][name=preset_invoice_dates]').change(function(e) {
    var input = $(this).val(),
        timestamp = Date.parse(input),
        dateField = document.querySelector("#level_of_participation_invoice_date");

    if(isNaN(timestamp)) {
      dateField.value = null;
    } else {
      dateField.value = input;
    }
  });

  // Show either the contact dropdown or the new fields for
  // organizations without a financial contact
  var modeSelector = $("input[name='level_of_participation[financial_contact_action]']");
  if(modeSelector.length > 0) {
    var toggleInputField = function() {
      var dropdown = $("#financial-contact-selector"),
          fields = $("#financial-contact-fields"),
          choice;

      var choice = $("input[name='level_of_participation[financial_contact_action]']:checked").val();
      dropdown.toggle(choice === "choose");
      fields.toggle(choice === "create");
    };
    modeSelector.change(toggleInputField);
    toggleInputField();
  }


});
