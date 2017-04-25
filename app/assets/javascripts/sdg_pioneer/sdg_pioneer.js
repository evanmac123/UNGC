$(function() {

  var $attachments = $('.attachments');

  function addAttachmentField($attachments) {
    var $template = $attachments.find('.attachment-template');
    var $container = $attachments.find('.attachment-container')
    var nextId = $container.find('.attachment').length + 1;

    var $newField = $($template.html());
    $container.append($newField);
  }

  $attachments.on('click', '.delete', function(e) {
    e.preventDefault();
    var $attachment = $(this).parent('.attachment');
    $attachment.remove();
  });

  $('.add-another-attachment').on('click', function(e) {
    e.preventDefault();
    addAttachmentField($(this).parent('.attachments'));
  });

  $("#submission_organization_name").autocomplete({
    source: "/api/v1/autocomplete/sdg_pioneer_submissions.json"
  });

  $("#other_organization_name").autocomplete({
    source: "/api/v1/autocomplete/sdg_pioneer_submissions.json"
  });

  $("#submission_country_name").autocomplete({
    source: "/api/v1/autocomplete/countries.json"
  });

  var $extraNominationFields = $('#has_been_nominated');
  $("[name='submission[is_nominated]']").on('change', function(e) {
    var isNominated = $(e.target).val() === 'true';

    if(isNominated) {
      $extraNominationFields.show();
      $extraNominationFields.find('input').removeAttr('disabled');
    } else {
      $extraNominationFields.hide();
      $extraNominationFields.find('input').attr('disabled', 'disabled');
    }

  });

  var $organizationField = $('#ungc-participant');
  var $joinDialog = $('#join-ungc');
  var submitButton = $('#nominate-pioneer');
  var yesButton = $('#submission_is_participant_true, #other_is_participant_true');
  var noButton = $('#submission_is_participant_false, #other_is_participant_false');

  function showParticipantField() {
    $organizationField.show();
    $joinDialog.hide();
    submitButton.show();
  }

  function disableSdgForm() {
    $organizationField.hide();
    $joinDialog.show();
    submitButton.hide();
  }

  function disableFormAndParticipantField() {
    $organizationField.hide();
    $joinDialog.hide();
    submitButton.hide();
  }

  yesButton.on('click', showParticipantField);
  noButton.on('click', disableSdgForm);

  var yesButtonChecked = yesButton.filter(":checked").length > 0;
  var noButtonChecked = noButton.filter(":checked").length > 0;

  if(yesButtonChecked) {
    showParticipantField();
  } else if (noButtonChecked) {
    disableSdgForm();
  } else {
    disableFormAndParticipantField();
  }

});
