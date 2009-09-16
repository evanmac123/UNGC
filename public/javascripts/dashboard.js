$("#organization_organization_type_id").change(function() {
  if ($("#organization_organization_type_id option:selected").text() == "Company") {
	$('#company_only').show();
  } else {
	$('#company_only').hide();
  }
})

$("#organization_listing_status_id").change(function() {
  if ($("#organization_listing_status_id option:selected").text() == "Public Company") {
	$('#public_company_only').show();
  } else {
	$('#public_company_only').hide();
  }
})
