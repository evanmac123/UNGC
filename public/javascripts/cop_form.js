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
$("input[class='additional_questions']").change(function() {
  if ($("#communication_on_progress_notable_program_true").is(':checked')) {
	$("#notable_questions").show();
	$("#additional_questions").show();
  } else if ($("#communication_on_progress_additional_questions_true").is(':checked')) {
	$("#notable_questions").hide();
	$("#additional_questions").show();
  } else {
	$("#notable_questions").hide();
	$("#additional_questions").hide();
  }
})

// COP score and area questions
$("input[class='score']").change(function() {
  score = 0;
  if ($("#communication_on_progress_references_human_rights_true").is(':checked') ||
		$("#communication_on_progress_concrete_human_rights_activities_true").is(':checked')) {
    score = score + 1;
    $("#human_rights_additional_questions").show();
  } else {
    $("#human_rights_additional_questions").hide();
  }
  if ($("#communication_on_progress_references_labour_true").is(':checked') ||
		$("#communication_on_progress_concrete_labour_activities_true").is(':checked')) {
    score = score + 1;
    $("#labour_additional_questions").show();
  } else {
    $("#labour_additional_questions").hide();
  }
  if ($("#communication_on_progress_references_environment_true").is(':checked') ||
		$("#communication_on_progress_concrete_environment_activities_true").is(':checked')) {
    score = score + 1;
    $("#environment_additional_questions").show();
  } else {
    $("#environment_additional_questions").hide();
  }
  if ($("#communication_on_progress_references_anti_corruption_true").is(':checked') ||
		$("#communication_on_progress_concrete_anti_corruption_activities_true").is(':checked')) {
    score = score + 1;
    $("#anti_corruption_additional_questions").show();
  } else {
    $("#anti_corruption_additional_questions").hide();
  }
  if (score == 3) {
    $("#only_3_areas_selected").show();

    // find out what the missing area is
    var areas = { human_rights:"Human Rights", labour:"Labour", environment:"Environment", anti_corruption:"Anti-Corruption" };
	jQuery.each(areas, function(key, val) {
	  if ($("#communication_on_progress_references_" + key + "_false").is(':checked') &&
	  	  $("#communication_on_progress_concrete_" + key + "_activities_false").is(':checked')) {
		area = val;
	  }
	});
    $("#last_issue_area").text(area);
  } else {
    $("#only_3_areas_selected").hide();
  }
})

// partnership project
$("input[name='communication_on_progress[mentions_partnership_project]']").change(function() {
  if ($("#communication_on_progress_mentions_partnership_project_true").is(':checked')) {
	$("#partnership_additional_questions").show();
  } else {
	$("#partnership_additional_questions").hide();
  }
})
