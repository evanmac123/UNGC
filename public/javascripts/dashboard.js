$("#organization_organization_type_id").change(function() {
  org_type = $("#organization_organization_type_id option:selected").text(); 
  if (org_type == "Company" || org_type == "SME") {
    $('.company_only').show();
  } else {
    $('.company_only').hide();
    $('.public_company_only').hide();
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
    $("#delisted_only").hide('slow');
    $('#organization_delisted_on').attr('value', '');
    $("#organization_removal_reason_id option[value='1']").attr('selected', 'selected');
  }
  else {
    $("#delisted_only").show('slow');
  } 
})
  
// called from views/signup/step4.html.haml
$("#organization_pledge_amount_0").click(function() {
  $('#organization_pledge_amount_other').focus();
})

// contact form
$('.role_for_login_fields').change(function() {
  if ($(".role_for_login_fields:checked").length > 0) {
    $('#login_information').show();
  } else {
    $('#login_information').hide();
  }
})

replace_ids = function(s){
  var new_id = new Date().getTime();
  return s.replace(/NEW_RECORD/g, new_id);
}