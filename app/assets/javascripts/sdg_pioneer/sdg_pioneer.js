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

  $("#business_organization_name").autocomplete({
    source: "/api/v1/autocomplete/sdg_pioneer_businesses.json"
  });

  $("#individual_organization_name").autocomplete({
    source: "/api/v1/autocomplete/participants.json"
  });

  $("#business_country_name").autocomplete({
    source: "/api/v1/autocomplete/countries.json"
  });

  var $extraNominationFields = $('#has_been_nominated');
  $("[name='individual[is_nominated]'], [name='business[is_nominated]']").on('change', function(e) {
    var isNominated = $(e.target).val() === 'true';

    if(isNominated) {
      $extraNominationFields.show();
      $extraNominationFields.find('input').removeAttr('disabled');
    } else {
      $extraNominationFields.hide();
      $extraNominationFields.find('input').attr('disabled', 'disabled');
    }

  });

});
