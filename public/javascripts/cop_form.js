// Q1 - Format
$("input[name='communication_on_progress[format]']").change(function() {
  if ($("#communication_on_progress_format_grace_letter").is(':checked')) {
    // grace letters only require a upload
    $("#non_grace_letter_fields").hide();
    showAndEnableFormElements("#grace_letter_fields");
    hideAndDisableFormElements("#cop_attachments");
    hideAndDisableFormElements("#web_cop_attachments");
    $("#web_cop_attachments").hide();
    $("#text_a").show();
  } else {
    hideAndDisableFormElements("#grace_letter_fields");
    $("#text_a").hide();
    $("#non_grace_letter_fields").show();
    showAndEnableFormElements("#cop_attachments");
    showAndEnableFormElements("#web_cop_attachments");
  }
})

// Q2 - Web based
$("input[name='communication_on_progress[web_based]']").change(function() {
  if ($("#communication_on_progress_web_based_true").is(':checked')) {
    showAndEnableFormElements("#web_cop_attachments");
    hideAndDisableFormElements("#cop_attachments");
    $("#text_b").show();
  } else {
    showAndEnableFormElements("#cop_attachments");
    hideAndDisableFormElements("#web_cop_attachments");
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

// Q5 - A statement of continued support is required
$("input[name='communication_on_progress[include_continued_support_statement]']").change(function() {
  if ($("#communication_on_progress_include_continued_support_statement_true").is(':checked')) {
    $("#explicit_statement_of_support_fields").show();
    $("#reject_cop").hide();
    $("#text_d").hide();
  } else {
    $("#explicit_statement_of_support_fields").hide();
    $("#reject_cop").show();
    $("#text_d").show();
  }
})

// Q6 - Reject if COP is not signed by a executive
$("input[name='communication_on_progress[support_statement_signee]']").change(function() {
  if ($("#communication_on_progress_support_statement_signee_none").is(':checked')) {
    $("#signed_by_executive_fields").hide();
    $("#reject_cop").show();
    $("#text_e").show();
  } else {
    $("#signed_by_executive_fields").show();
    $("#reject_cop").hide();
    $("#text_e").hide();
  }
})

// Q7 - COP score and area questions
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
    if (participant_for_more_than_5_years) {
      $("#only_3_areas_selected").show();

      // find out what the missing area is
      var areas = { human_rights:"Human Rights",
                    labour:"Labour",
                    environment:"Environment",
                    anti_corruption:"Anti-Corruption" };
      area = '';
      jQuery.each(areas, function(key, val) {
        if ($("#communication_on_progress_references_" + key + "_false").is(':checked')) {
          area = val;
        }
      });
      $("#last_issue_area").text(area);
    }
  } else {
    $("#only_3_areas_selected").hide();
  }
  // take decisions based on organization details and score
  reject_cop = true;
  text_to_display = '';
  if (joined_after_july_09) {
    if (participant_for_more_than_5_years) {
      // participant for more than 5 years who joined after July 1st 2009
      if ((score == 4 && $("#communication_on_progress_include_measurement_true").is(':checked')) || 
          (score == 3 && $("#communication_on_progress_include_measurement_true").is(':checked') && $("#communication_on_progress_missing_principle_explained_true").is(':checked'))) {
        reject_cop = false;
      } else {
        text_to_display = '#text_g';
      }
    } else {
      // participant for less than 5 years who joined after July 1st 2009
      if (score >= 2 && $("#communication_on_progress_include_measurement_true").is(':checked')) {
        reject_cop = false;
      } else {
        text_to_display = '#text_f';
      }
    }
  } else {
    if (participant_for_more_than_5_years) {
      // participant for more than 5 years who joined before July 1st 2009
      if ((score == 4 && $("#communication_on_progress_include_measurement_true").is(':checked')) || 
          (score == 3 && $("#communication_on_progress_include_measurement_true").is(':checked') && $("#communication_on_progress_missing_principle_explained_true").is(':checked'))) {
        reject_cop = false;
      } else {
        text_to_display = '#text_i';
      }
    } else {
      // participant for less than 5 years who joined before July 1st 2009
      if (score >= 2 && $("#communication_on_progress_include_measurement_true").is(':checked')) {
        reject_cop = false;
      } else {
        text_to_display = '#text_h';
      }
    }
  }
  // time to show/hide divs
  if (reject_cop) {
    $("#reject_cop").show();
    $("#approved_cop").hide();
    $(text_to_display).show();
  } else {
    $("#reject_cop").hide();
    $("#approved_cop").show();
    // hide texts F to I
    $("#text_f").hide();
    $("#text_g").hide();
    $("#text_h").hide();
    $("#text_i").hide();
  }
})

// Q16 & Q17 - Additional questions
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
  // defining text to display
  $("#text_l").hide();
  $("#text_m").hide();
  $("#text_n").hide();
  $("#text_o").hide();
  
  if ($("#communication_on_progress_notable_program_true").is(':checked') &&
      $("#communication_on_progress_additional_questions_true").is(':checked')) {
    $("#text_l").show();
  } else if ($("#communication_on_progress_notable_program_true").is(':checked') &&
             $("#communication_on_progress_additional_questions_false").is(':checked')) {
    $("#text_m").show();
  } else if ($("#communication_on_progress_notable_program_false").is(':checked') &&
             $("#communication_on_progress_additional_questions_true").is(':checked')) {
    $("#text_n").show();
  } else if ($("#communication_on_progress_notable_program_false").is(':checked') &&
             $("#communication_on_progress_additional_questions_false").is(':checked')) {
    $("#text_o").show();
  }
})

function hideAndDisableFormElements(div) {
  $(div).hide();
  $(div + " input, " + div + " select").attr("disabled", "disabled");
}

function showAndEnableFormElements(div) {
  $(div).show();
  $(div + " input, " + div + " select").attr("disabled", "");
}
