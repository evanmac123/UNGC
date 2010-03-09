// Q1 - Format
$("input[name='communication_on_progress[format]']").click(function() {
  if ($("#communication_on_progress_format_grace_letter").is(':checked')) {
    // grace letters only require a upload
    $("#non_grace_letter_fields").hide();
    showAndEnableFormElements("#grace_letter_fields");
    hideAndDisableFormElements("#cop_attachments");
    hideAndDisableFormElements("#web_cop_attachments");
    $("#text_a").show();
    $("#submit_tab").show();
  } else {
    $("#non_grace_letter_fields").show();
    hideAndDisableFormElements("#grace_letter_fields");
    showCopFileOrLinks();
    $("#text_a").hide();
    $("#submit_tab").hide();
  }
})

function showCopFileOrLinks() {
  if ($("#communication_on_progress_web_based_true").is(':checked')) {
    showAndEnableFormElements("#web_cop_attachments");
    hideAndDisableFormElements("#cop_attachments");
    $("#text_b").show();
  } else {
    showAndEnableFormElements("#cop_attachments");
    hideAndDisableFormElements("#web_cop_attachments");
    $("#text_b").hide();
  }
}

// Q2 - Web based
$("input[name='communication_on_progress[web_based]']").click(function() {
  showCopFileOrLinks();
})

// Q5 - A statement of continued support is required
$("input[name='communication_on_progress[include_continued_support_statement]']").click(function() {
  if ($("#communication_on_progress_include_continued_support_statement_true").is(':checked')) {
    $("#include_continued_support_statement").show();
    $("#reject_cop").hide();
    $("#text_d").hide();
  }
  else {
    $("#include_continued_support_statement").show();
    $("#reject_cop").hide();
    $("#text_d").hide();
  }
})

$("input[name='communication_on_progress[include_measurement]']").click(function() {
  // $("#approved_cop").show();
  $("#submit_tab").show();
})

// Q16 & Q17 - Additional questions
$("input[class='additional_questions']").click(function() {
  if ($("#communication_on_progress_notable_program_true").is(':checked')) {
    $("#notable_tab").show();
    $(".tab_nav .additional_questions").show();
  } else if ($("#communication_on_progress_additional_questions_true").is(':checked')) {
    $("#notable_tab").hide();
    $(".tab_nav .additional_questions").show();
  } else {
    $("#notable_tab").hide();
    $(".tab_nav .additional_questions").hide();
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

// Q17 - Notable program
$("input[name='communication_on_progress[notable_program]']").click(function() {
  // display the submit tab after a selection is made
  $("#submit_tab").show();
})

function hideAndDisableFormElements(div) {
  $(div).hide();
  $(div + " input, " + div + " select").attr("disabled", "disabled");
}

function showAndEnableFormElements(div) {
  $(div).show();
  $(div + " input, " + div + " select").attr("disabled", "");
}

$('#cop_form').submit(function() {
  window.onbeforeunload = null;
  // We disable the upload elements for a web based COP if a file wasn't selected
  if ( $("#communication_on_progress_web_based_true").is(':checked') &&
      ($("#communication_on_progress_cop_files_attributes_new_web_cop_attachment").val() == "")) {
        $("#cop_file_new_web_cop input, #cop_file_new_web_cop select").attr("disabled", "disabled");
  }
})

$("#cop_form input, #cop_form select").change(function() {
  work_in_progress = true;
})

$(document).ready(function() {
  // tell the browser to warn before navigating away
  window.onbeforeunload = function() {
    if (work_in_progress) {
      return "Your COP submission will not be saved.";
    }
  }
;});
