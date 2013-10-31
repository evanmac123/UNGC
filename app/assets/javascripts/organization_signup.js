$(function(){
  // called from signup/step6.html.haml and /admin/organizations/_default_form.html.haml
  $("#non_business_organization_registration_mission_statement").change(function() {
    if (this.value.length >= 1000) {
      alert("Sorry, the Mission Statement must be less than 1000 characters.");
    }
  });

  if(noErrors()){
    hideLegalStatus();
  }

  $('#new_organization').submit(function(e){
    if(emptyNumber()){
      showLegalStatus();
    }

    if(emptyNumber() && emptyStatus()){
      return false
    }

    return true
  });

  function emptyNumber(){
    return $('#non_business_organization_registration_number').val().trim() === "";
  }
  function emptyStatus(){
    return $('#organization_legal_status').val().trim() === "";
  }
  function noErrors(){
    return $('#errorExplanation').length === 0;
  }
  function showLegalStatus(){
    $('.legal-status').show();
  }
  function hideLegalStatus(){
    $('.legal-status').hide();
  }
});

