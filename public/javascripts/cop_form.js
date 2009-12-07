// COP form
$("#communication_on_progress_references_human_rights").change(function() {
  if ($('#communication_on_progress_references_human_rights:checked').is(':checked')) {
	$('#human_rights_addressed').show();
	$('#human_rights_not_addressed').hide();
  } else {
	$('#human_rights_addressed').hide();
	$('#human_rights_not_addressed').show();
  }
})

$("#communication_on_progress_references_labour").change(function() {
  if ($('#communication_on_progress_references_labour:checked').is(':checked')) {
	$('#labour_addressed').show();
	$('#labour_not_addressed').hide();
  } else {
	$('#labour_addressed').hide();
	$('#labour_not_addressed').show();
  }
})

$("#communication_on_progress_references_environment").change(function() {
  if ($('#communication_on_progress_references_environment:checked').is(':checked')) {
	$('#environment_addressed').show();
	$('#environment_not_addressed').hide();
  } else {
	$('#environment_addressed').hide();
	$('#environment_not_addressed').show();
  }
})

$("#communication_on_progress_references_anti_corruption").change(function() {
  if ($('#communication_on_progress_references_anti_corruption:checked').is(':checked')) {
	$('#anti_corruption_addressed').show();
	$('#anti_corruption_not_addressed').hide();
  } else {
	$('#anti_corruption_addressed').hide();
	$('#anti_corruption_not_addressed').show();
  }
})

// Format
$("input[name='communication_on_progress[format]']").change(function() {
  if ($("#communication_on_progress_format_grace_letter").is(':checked')) {
	// grace letters only require a upload
	$("#grace_letter_fields").show();
	$("#non_grace_letter_fields").hide();
	$("#cop_links").hide();
	$("#cop_files").hide();
  } else {
	$("#grace_letter_fields").hide();
	$("#non_grace_letter_fields").show();
    if ($("#communication_on_progress_format_web_based").is(':checked')) {
	  $("#cop_links").show();
	  $("#cop_files").hide();
    } else {
	  $("#cop_links").hide();
	  $("#cop_files").show();
	}
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

// Statement of support question
$("input[name='communication_on_progress[statement_location]']").change(function() {
  if ($("#communication_on_progress_statement_location_document").is(':checked')) {
	$("#statement_support_pdf").show();
	$("#statement_support_link").hide();
  } else if ($("#communication_on_progress_statement_location_web").is(':checked')) {
	$("#statement_support_pdf").hide();
	$("#statement_support_link").show();
  } else {
	$("#statement_support_pdf").hide();
	$("#statement_support_link").hide();
}
})

// Parent company COP
$("input[name='communication_on_progress[parent_company_cop]']").change(function() {
  if ($("#communication_on_progress_parent_company_cop_true").is(':checked')) {
	$("#parent_company_question").show();
	$("#own_company_questions").hide();
  } else {
	$("#parent_company_question").hide();
	$("#own_company_questions").show();
  }
})

// Parent COP covers subsidiary
$("input[name='communication_on_progress[parent_cop_cover_subsidiary]']").change(function() {
  if ($("#communication_on_progress_parent_cop_cover_subsidiary_true").is(':checked')) {
	$("#reject_cop").hide();
  } else {
	$("#reject_cop").show();
  }
})

// Additional questions
$("input[name='communication_on_progress[additional_questions]']").change(function() {
  if ($("#communication_on_progress_additional_questions_true").is(':checked')) {
	$("#additional_questions").show();
  } else {
	$("#additional_questions").hide();
  }
})
