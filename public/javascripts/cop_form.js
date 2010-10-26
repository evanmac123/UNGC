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
    showAndEnableFormElements("#web_cop_attachments");
    showAndEnableFormElements("#cop_attachments");
    $("#text_b").show();
    // showCopFileOrLinks();
    $("#text_a").hide();
    $("#submit_tab").hide();
  }
})

// function showCopFileOrLinks() {
//   if ($("#communication_on_progress_web_based_true").is(':checked')) {
//     showAndEnableFormElements("#web_cop_attachments");
//     hideAndDisableFormElements("#cop_attachments");
//     $("#text_b").show();
//   } else {
//     showAndEnableFormElements("#cop_attachments");
//     hideAndDisableFormElements("#web_cop_attachments");
//     $("#text_b").hide();
//   }
// }

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

// Answered last required question, so show optional questions
$("input[name='communication_on_progress[include_measurement]']").click(function() {
  $("#submit_tab").show();
})


// Q16 & Q17 - Additional questions
$("input[class='additional_questions']").click(function() {
  if ($("#communication_on_progress_additional_questions_true").is(':checked')) {
    $(".tab_nav .additional_questions").show();
    $("#text_m").show();
    $("#text_p").hide();
  }
  else {
    $(".tab_nav .additional_questions").hide();
    $("#text_p").show();
    $("#text_m").hide();
  }
  $("#submit_tab").show();
  
})

// Q17 - Notable program
$("input[name='communication_on_progress[notable_program]']").click(function() {
  // display the submit tab after a selection is made
  $("#submit_tab").show();
})

// Show and Hide question hints
// $("div.hint_toggle").toggle(function(){
//  $(this).addClass("active"); 
//  }, function () {
//  $(this).removeClass("active");
// });

$(".hint_toggle").click(function(){
  $(this).next(".hint_text").slideToggle('slow');
});


function hideAndDisableFormElements(div) {
  $(div).hide();
  $(div + " input, " + div + " select").attr("disabled", "disabled");
}

function showAndEnableFormElements(div) {
  $(div).show();
  $(div + " input, " + div + " select").attr("disabled", "");
}

$('#cop_form').submit(function() {
  $('input[type=submit]', this).attr('disabled', 'disabled');
  window.onbeforeunload = null;
  // We disable the upload elements for a web based COP if no URL was provided
  if ( $("#communication_on_progress_cop_links_attributes_new_cop_url").val().trim() == "" ) {
        hideAndDisableFormElements("#web_cop_attachments");
  }
})

$("#cop_form input, #cop_form select, #cop_form textarea").change(function() {
  work_in_progress = true;
})

$(document).ready(function() {
  // preselect Submit tab
  if (submitted == 1) {
    $('#basic').hide();
    $('#finish').show();
    $('#submit_link').addClass("selected");
    $('#basic_link').removeClass("selected");
  }
  
  // tell the browser to warn before navigating away
  window.onbeforeunload = function() {
    if (work_in_progress) {
      return "Your COP submission will NOT be saved.";
    }
  }
;});
