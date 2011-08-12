$("#organization_organization_type_id").change(function() {
  org_type = $("#organization_organization_type_id option:selected").text(); 
  if (org_type == "Company" || org_type == "SME") {
    $('.company_only').show('slow');
  } else {
    $('.company_only').hide('slow');
    $('.public_company_only').hide('slow');
  }
})

$("#organization_listing_status_id").change(function() {
  selected_listing_status = jQuery.trim($("#organization_listing_status_id option:selected").text());
  if (selected_listing_status == "Public Company") {
    $('.public_company_only').show();
  } else {
    $('.public_company_only').hide();
  }
})

// used to set delisting date/reason when Active is unchecked
$("#organization_active").change(function() {
  if ($("#organization_active").is(':checked')) {
    $("#delisted_only").hide();
    $('#organization_delisted_on').attr('value', '');
    $("#organization_removal_reason_id option[value='1']").attr('selected', 'selected');
  }
  else {
    $("#delisted_only").toggle();
  } 
})

// used when 'No Dialogue' is set
$("#organization_non_comm_dialogue").change(function() {
  if ($("#organization_non_comm_dialogue").is(':checked')) {
    $("#non_comm_dialogue_only").show();
  }
  else {
    $("select[id^=organization_non_comm_dialogue_on_]").val($("select[id^=organization_non_comm_dialogue_on_] option:first").val());
    $("#non_comm_dialogue_only").toggle();
  } 
})
  
// contact form
$('.role_for_login_fields').change(function() {
  if ($(".role_for_login_fields:checked").length > 0) {
    $('#login_information').show();
  } else {
    $('#login_information').hide();
  }
})

// search
$("#admin_search").focus(function() {
  $('#admin_search').attr('value', '');
})
$("#admin_search").blur(function() {
  $('#admin_search').attr('value', 'Search organizations');
})


replace_ids = function(s){
  var new_id = new Date().getTime();
  return s.replace(/NEW_RECORD/g, new_id);
}