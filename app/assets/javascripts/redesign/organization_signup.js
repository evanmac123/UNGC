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

  function showBusinessOnly (argument) {
    $('.for_stakeholders_only').fadeOut('slow');
    $('.for_business_only').fadeIn('slow');
  }

  function showStakeholdersOnly (argument) {
    $('.for_business_only').fadeOut('slow');
    $('.for_stakeholders_only').fadeIn('slow');
  }

  function hideBusinessAndStakeholders (argument) {
    $('.for_stakeholders_only').fadeOut('slow');
    $('.for_business_only').fadeOut('slow');
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

  $('body').on('click', 'form #business_only', showBusinessOnly);
  $('body').on('click', 'form #stakeholders_only', showStakeholdersOnly);
  $('body').on('click', 'form #hide_business_and_stakeholders', hideBusinessAndStakeholders);
  $('body').on('change', '#listing_status_id', function() {
    selected_listing_status = jQuery.trim($("#listing_status_id option:selected").text());
    if (selected_listing_status === "Publicly Listed") {
      console.log('test');
      $('.public_company_only').show();
    } else {
      $('.public_company_only').hide();
    }
  });

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

  $('.fixed_pledge').on('change', function() {
    togglePledgeReason();
  });

  // called from views/signup/step5.html.haml
  $("body").on("click", "#contact_foundation_contact", function() {
    $('#errorExplanation').toggle();
    $('#contact_form').toggle();
  });
});
