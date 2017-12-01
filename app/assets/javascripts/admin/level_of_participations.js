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
    centsLimit: 2,
    clearOnEmpty: true
  });

  var toggleInvoiceDateSelector = function() {
    var revenueInCents = $revenue.unmask(),
        businessModel = $revenue.data("type"),
        showInvoiceDate = false;

    if(businessModel === "global_local") {
      var threshold = $revenue.data("threshold-in-cents");
      if(revenueInCents >= threshold) {
        showInvoiceDate = $revenue.data("global");
      } else {
        showInvoiceDate = $revenue.data("local");
      }
    } else {
      showInvoiceDate = $revenue.data("value");
    }

    $invoiceDate.toggle(showInvoiceDate);
    $invoiceDate.prop("disabled", !showInvoiceDate);
  };

  toggleInvoiceDateSelector();
  $revenue.keyup(toggleInvoiceDateSelector);

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
          choice = $("input[name='level_of_participation[financial_contact_action]']:checked").val();

      dropdown.toggle(choice === "choose");
      fields.toggle(choice === "create");
    };
    modeSelector.change(toggleInputField);
    toggleInputField();
  }

  // show/hide the action platform selection box
  var levelSelector = $("input[name='level_of_participation[level_of_participation]']");
  if(levelSelector.length > 0) {
    var toggleApSelector = function() {
      var selector = $("#action-platform-selector"),
          choice = $("input[name='level_of_participation[level_of_participation]']:checked").val(),
          ap_eula_label = $("label[for='level_of_participation_accept_platform_removal']"),
          ap_eula_checkbox = $("#level_of_participation_accept_platform_removal"),
          isLead = choice === "lead_level";


      selector.toggle(isLead);
      ap_eula_label.toggle(isLead);
      ap_eula_checkbox.toggle(isLead);
      ap_eula_checkbox.prop("disabled", !isLead);
    };
    levelSelector.change(toggleApSelector);
    toggleApSelector();
  }

});
