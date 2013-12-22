$(function(){

  // step1 for non_business
  var hidden = false;
  function isNonBusiness(){
    return $('#org_type').val() === 'non_business';
  }
  function emptyNumber(){
    return $.trim($('#non_business_organization_registration_number').val()) === "";
  }
  function emptyStatus(){
    return $.trim($('#organization_legal_status').val()) === "";
  }
  function noErrors(){
    return $('#errorExplanation').length === 0;
  }
  function showLegalStatus(){
    $('.legal-status').show('fade');
    hidden = false;
  }
  function hideLegalStatus(){
    hidden = true;
    $('.legal-status').hide();
  }

  if(noErrors() || !emptyNumber()){
    hideLegalStatus();
  }

  $('#new_organization').submit(function(e){
    var ret = true;

    if(isNonBusiness() && emptyNumber() && emptyStatus()){
      if(hidden === false) alert("Either a registration number or proof of legal status is required");
      ret = false;
    }

    if(isNonBusiness() && emptyNumber()){
      showLegalStatus();
    }

    return ret;
  });

  // called from signup/step6.html.haml and /admin/organizations/_default_form.html.haml
  $("#non_business_organization_registration_mission_statement").change(function() {
    if (this.value.length >= 1000) {
      alert("Sorry, the Mission Statement must be less than 1000 characters.");
    }
  });

});

