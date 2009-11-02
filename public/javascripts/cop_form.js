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

$("#communication_on_progress_references_environment").change(function() {
  if ($('#communication_on_progress_references_environment:checked').is(':checked')) {
	$('#environment_addressed').show();
	$('#environment_not_addressed').hide();
  } else {
	$('#environment_addressed').hide();
	$('#environment_not_addressed').show();
  }
})

$("#communication_on_progress_references_anti_corruption").change(function() {
  if ($('#communication_on_progress_references_anti_corruption:checked').is(':checked')) {
	$('#anti_corruption_addressed').show();
	$('#anti_corruption_not_addressed').hide();
  } else {
	$('#anti_corruption_addressed').hide();
	$('#anti_corruption_not_addressed').show();
  }
})
