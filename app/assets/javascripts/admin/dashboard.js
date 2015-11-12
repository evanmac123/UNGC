$(document).ready(function() {

  // app/views/admin/sign_in_as/_form.html.haml
  $("#sign_in_as_id").select2({
    placeholder: 'Search for a participant or a person by name',
    allowClear: true,
    ajax: {
      url: "/admin/sign-in-as/contacts.json",
      dataType: 'json',
      delay: 250,
      data: function (params) {
        return { term: params.term };
      },
      processResults: function (data, params) {
        return { results: data };
      },
      cache: true
    },
    escapeMarkup: function (markup) { return markup; },
    minimumInputLength: 2,
    templateResult: function(selection) {
      if (selection.loading) {
        return selection.text;
      } else {
        return "<div class='select2-result-repository clearfix'>" + selection.label +"</div>";
      }
    },
    templateSelection: function(selection) {
      if(!selection.label) {
        return selection.text; // the placeholder
      }

      return selection.contact_name + " of <strong>" + selection.label + "</strong>";
    }
  });

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

  // called from /app/views/admin/contribution_descriptions/_default_form.html.haml
  $('.contribution_descriptions.maxlength').change(function() {
    if (this.value.length >= 500) {
      alert("Sorry, this text must be less than 500 characters.");
    }
  });

  $('#add_pledge_continued').click(function(e) {
    e.preventDefault();
    $(this).next(".show_field_target").slideToggle();
  });


}); // end $(document).ready(function()

var replace_ids = function(s){
  var new_id = new Date().getTime();
  return s.replace(/NEW_RECORD/g, new_id);
};
