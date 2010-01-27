// Q1 - Format
$("input[name='communication_on_progress[format]']").change(function() {
  if ($("#communication_on_progress_format_grace_letter").is(':checked')) {
    // grace letters only require a upload
    $("#grace_letter_fields").show();
    $("#non_grace_letter_fields").hide();
    $("#cop_links").hide();
    $("#cop_files").hide();
    $("#grace_letter_fields").show();
    $("#text_a").show();
  } else {
    $("#grace_letter_fields").hide();
    $("#text_a").hide();
    $("#non_grace_letter_fields").show();
  }
})

// Q2 - Web based
$("input[name='communication_on_progress[web_based]']").change(function() {
  if ($("#communication_on_progress_web_based_true").is(':checked')) {
    $("#cop_links").show();
    $("#cop_files").hide();
    $("#text_b").show();
  } else {
    $("#cop_links").hide();
    $("#cop_files").show();
    $("#text_b").hide();
  }
})

// Q3 - Parent company COP
$("input[name='communication_on_progress[parent_company_cop]']").change(function() {
  if ($("#communication_on_progress_parent_company_cop_true").is(':checked')) {
    $("#parent_company_question").show();
    $("#own_company_questions").hide();
  } else {
    $("#parent_company_question").hide();
    $("#own_company_questions").show();
  }
})

// Q4 - Parent COP covers subsidiary
$("input[name='communication_on_progress[parent_cop_cover_subsidiary]']").change(function() {
  if ($("#communication_on_progress_parent_cop_cover_subsidiary_true").is(':checked')) {
    // if Yes, end of submission
    $("#reject_cop").hide();
    $("#text_c").hide();
  } else {
    // if No, reject COP, show Text C
    $("#reject_cop").show();
    $("#text_c").show();
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

// Additional questions
$("input[class='additional_questions']").change(function() {
  if ($("#communication_on_progress_notable_program_true").is(':checked')) {
  $("#notable_tab").show();
  $("#additional_questions").show();
  } else if ($("#communication_on_progress_additional_questions_true").is(':checked')) {
  $("#notable_tab").hide();
  $("#additional_questions").show();
  } else {
  $("#notable_tab").hide();
  $("#additional_questions").hide();
  }
})

// COP score and area questions
$("input[class='score']").change(function() {
  score = 0;
  if ($("#communication_on_progress_references_human_rights_true").is(':checked')) {
    score = score + 1;
    $("#human_rights_tab").show();
  } else {
    $("#human_rights_tab").hide();
  }
  if ($("#communication_on_progress_references_labour_true").is(':checked')) {
    score = score + 1;
    $("#labour_tab").show();
  } else {
    $("#labour_tab").hide();
  }
  if ($("#communication_on_progress_references_environment_true").is(':checked')) {
    score = score + 1;
    $("#environment_tab").show();
  } else {
    $("#environment_tab").hide();
  }
  if ($("#communication_on_progress_references_anti_corruption_true").is(':checked')) {
    score = score + 1;
    $("#anti_corruption_tab").show();
  } else {
    $("#anti_corruption_tab").hide();
  }
  if (score == 3) {
    $("#only_3_areas_selected").show();

    // find out what the missing area is
    var areas = { human_rights:"Human Rights", labour:"Labour", environment:"Environment", anti_corruption:"Anti-Corruption" };
  jQuery.each(areas, function(key, val) {
    if ($("#communication_on_progress_references_" + key + "_false").is(':checked')) {
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
