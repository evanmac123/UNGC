$("#organization_organization_type_id").change(function() {
  if ($("#organization_organization_type_id option:selected").text() == "Company") {
	$('#company_only').show();
  } else {
	$('#company_only').hide();
  }
})

$("#organization_listing_status_id").change(function() {
  selected_listing_status = jQuery.trim($("#organization_listing_status_id option:selected").text());
  if (selected_listing_status == "Public Company") {
	$('#public_company_only').show();
  } else {
	$('#public_company_only').hide();
  }
})

// called from views/signup/step4.html.haml
$("#organization_pledge_amount_1").click(function() {
  $('#organization_pledge_amount_other').focus();
})