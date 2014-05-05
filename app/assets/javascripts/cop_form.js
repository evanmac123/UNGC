function hideAndDisableTabbedSection(div) {
  formElementsFor(div).attr("disabled", "disabled");
}

function showAndEnableTabbedSection(div) {
  formElementsFor(div).removeAttr("disabled");
}

function hideAndDisableFormElements(div) {
  $(div).hide('slow');
  formElementsFor(div).attr("disabled", "disabled");
}

function showAndEnableFormElements(div) {
  $(div).fadeIn('slow');
  formElementsFor(div).removeAttr("disabled");
}

function formElementsFor(div) {
  return $(div + " input, " + div + " select, " + div + " textarea")
}

$(document).ready(function() {
  // preselect Submit tab
  if (typeof(submitted) != 'undefined' && submitted == 1) {
    $('#basic').hide();
    $('#finish').show();
    $('#text_b').show();
    $('#submit_link').addClass("selected");
    $('#basic_link').removeClass("selected");
  }

  // Format
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
      $("#non_grace_letter_fields").fadeIn('slow');
      hideAndDisableFormElements("#grace_letter_fields");
      showAndEnableFormElements("#web_cop_attachments");
      showAndEnableFormElements("#cop_attachments");
      $("#text_b").show();
      // showCopFileOrLinks();
      $("#text_a").hide();
      $("#submit_tab").hide();
    }
  })

  // A statement of continued support
  $("input[name='communication_on_progress[include_continued_support_statement]']").click(function() {
    $("#include_continued_support_statement").fadeIn('slow');
  })

  // Do you have operations in high-risk and/or conflict-affected areas?
  $("input[name='communication_on_progress[references_business_peace]']").click(function() {
    if ($("#communication_on_progress_references_business_peace_true").is(':checked')) {
      $("#business_peace_tab").slideDown();
      showAndEnableTabbedSection("#business_peace_additional_questions");
    }
    else {
      $("#business_peace_tab").slideUp();
      hideAndDisableTabbedSection("#business_peace_additional_questions");
    }
  })

  // Does your COP include qualitative and/or quantitative measurement of outcomes illustrating the degree to which targets/performance indicators were met?
  $("input[name='communication_on_progress[include_measurement]']").click(function() {
    $("#method_shared_with_stakeholders").fadeIn('slow');
  })

  // Answered last required question, so show submit tab
  $("input[name='communication_on_progress[method_shared]']").click(function() {
    $("#submit_tab").slideDown();
  })

  $("#new_cop_file").click(function(){
    $('#cop_files').append(replace_ids(cop_file_form));
  });

  $('#cop_form').submit(function() {
    $('input[type=submit]', this).attr('disabled', 'disabled');
    $('input[type=submit]', this).attr('value', 'Please wait...');
    window.onbeforeunload = null;
  })

  $("#cop_form input, #cop_form select, #cop_form textarea").change(function() {
    work_in_progress = true;
  })

  $(".open_question_toggle").change(function(){
    var _this = this;
    $(this).siblings('.label_text').children('.cop_answer_textarea').slideToggle(function() {
      if (_this.checked) { $(this).focus(); }
    });
    return true;
  });

  $(".cop_answer_textarea").click(function() { return false });

  $(".cop_answer_textarea").change(function() {
    var parent_val = $(this).parent().siblings('.open_question_toggle');
    if (parent_val.attr('checked') && this.value.length >= 255) {
      alert("Sorry, you may only enter up to 255 characters.");
    }
  });

  $(".cop_answer_textarea").blur(function() {
    var _this = this;
    setTimeout(function() {
      var parent_val = $(_this).parent().siblings('.open_question_toggle');
      if (parent_val.attr('checked') && !$.trim($(_this).val())) {
        alert("This option requires a description of the best practice.");
        parent_val.attr('checked', false);
        $(_this).slideToggle();
      }
    }, 100);
  });

  // tell the browser to warn before navigating away
  window.onbeforeunload = function() {
    if (typeof(work_in_progress) != 'undefined' && work_in_progress) {
      return "Your COP submission will NOT be saved.";
    }
  }
;});
