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

  // called from views/signup/pledge_form_*.html.haml
  // disable select if amount is chosen
  $('.fixed_pledge').on('click', function() {
    var result = (this.id !== 'organization_pledge_amount_250');
    $("#organization_pledge_amount").attr('disabled', result);
  });

  // called from views/signup/pledge_form_*.html.haml
  // hide select unless a pledge value is chosen

  function togglePledgeReason(){
    if ($("#organization_pledge_amount_0").is(':checked')) {
      $("#organization_no_pledge_reason").show();
    } else {
      $("#organization_no_pledge_reason").hide();
    }
  }

  togglePledgeReason();

  $('.fixed_pledge').on('click', function() {
    togglePledgeReason();
  });

});

