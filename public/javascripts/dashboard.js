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

replace_ids = function(s){
  var new_id = new Date().getTime();
  return s.replace(/NEW_RECORD/g, new_id);
}

// contact form
$('.role_for_login_fields').change(function() {
  if ($(".role_for_login_fields:checked").length > 0) {
	$('#login_information').show();
  } else {
	$('#login_information').hide();
  }
})

// COP form
// Format - grace letters only require a upload
$("input[name='communication_on_progress[format]']").change(function() {
  if ($("#communication_on_progress_format_grace_letter").is(':checked')) {
	$("#grace_letter_fields").show();
	$("#non_grace_letter_fields").hide();
  } else {
	$("#grace_letter_fields").hide();
	$("#non_grace_letter_fields").show();
  }
})

// A statement of continued support is required
$("input[name='communication_on_progress[include_continued_support_statement]']").change(function() {
  if ($("#communication_on_progress_include_continued_support_statement_true").is(':checked')) {
	$("#explicit_statement_of_support_fields").show();
	$("#reject_cop").hide();
  } else {
	$("#explicit_statement_of_support_fields").hide();
	$("#reject_cop").show();
  }
})

// Reject if COP is not signed by a executive
$("input[name='communication_on_progress[support_statement_signee]']").change(function() {
  if ($("#communication_on_progress_support_statement_signee_none").is(':checked')) {
	$("#signed_by_executive_fields").hide();
	$("#reject_cop").show();
  } else {
	$("#signed_by_executive_fields").show();
	$("#reject_cop").hide();
  }
})
