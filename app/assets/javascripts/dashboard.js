$(document).ready(function() {

  function toggleRegistrationFields(){
    var org_type = $("#organization_organization_type_id option:selected").text();
    if (org_type === "Company" || org_type === "SME") {
      $('.company_only').show('slow');
      $('.organization_registration').hide();
    } else if (org_type !== ""){
      $('.company_only').hide('slow');
      $('.public_company_only').hide('slow');
      $('.organization_registration').fadeIn();
    }
  }

  toggleRegistrationFields();

  $("#organization_organization_type_id").change(function() {
    toggleRegistrationFields();
  });

  $("#organization_listing_status_id").change(function() {
    var selected_listing_status = jQuery.trim($("#organization_listing_status_id option:selected").text());
    if (selected_listing_status === "Publicly Listed") {
      $('.public_company_only').show();
    } else {
      $('.public_company_only').hide();
    }
  });

  // /app/views/admin/organizations/_default_form.html.haml
  
  // used to set delisting date/reason when Delisted is manually selected
  $("input[id^=organization_cop_state_]").change(function() {
    if ($("#organization_cop_state_delisted").is(':checked')) {
      $("#delisted_only").show('slow');
    }
    else {
      $("#delisted_only").hide('slow');
      $('#organization_delisted_on').attr('value', '');
      $("#organization_removal_reason_id option[value='1']").attr('selected', 'selected');
    }
  });

  // used when 'No Dialogue' is set
  $("#organization_non_comm_dialogue").change(function() {
    if ($("#organization_non_comm_dialogue").is(':checked')) {
      $("#non_comm_dialogue_only").show('slow');
    }
    else {
      $('#organization_non_comm_dialogue_on').attr('value', '');
      $("#non_comm_dialogue_only").hide('slow');
    }
  });

  // contact form
  $('.role_for_login_fields').change(function() {
    if ($(".role_for_login_fields:checked").length > 0) {
      $('#login_information').show();
    } else {
      $('#login_information').hide();
    }
  });

  // search
  $("#admin_search").focus(function() {
    $('#admin_search').attr('value', '');
  });

  $("#admin_search").blur(function() {
    $('#admin_search').attr('value', 'Search organizations');
  });
});

var replace_ids = function(s){
  var new_id = new Date().getTime();
  return s.replace(/NEW_RECORD/g, new_id);
};
