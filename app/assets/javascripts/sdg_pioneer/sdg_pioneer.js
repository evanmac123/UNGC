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

  $(document).ready(function() {
    $('#ungc-participant').hide();
    $('#nominate-pioneer').hide();
    $('#join-ungc').hide();
    $('input[type="radio"]').click(function() {
      if($(this).attr('id') == 'submission_is_participant_true' || $(this).attr('id') == 'other_is_participant_true') {
        $('#ungc-participant').show();
        $('#join-ungc').hide();
      }
      else {
        $('#ungc-participant').hide();
        $('#join-ungc').show();
      }
    });

    $('input[type="radio"]').click(function() {
      if($(this).attr('id') == 'submission_is_participant_false' || $(this).attr('id') == 'other_is_participant_false') {
        $('#nominate-pioneer').hide();
      }
      else {
        $('#nominate-pioneer').show();
      }
    });
  });

});
