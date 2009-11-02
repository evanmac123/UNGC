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
