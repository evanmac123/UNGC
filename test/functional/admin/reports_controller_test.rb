require 'test_helper'

class Admin::ReportsControllerTest < ActionController::TestCase

  HtmlReports = [
    :all_cops,
    :approved_logo_requests,
    :contacts_excel_macro,
    :contacts_mail_merge,
    :cop_lead_submissions,
    :cop_water_mandate_submissions,
    :delisted_participants,
    :foundation_pledges,
    :index,
    # :initiative_organizations, # special cased below
    :listed_companies,
    :local_network_index,
    :local_network_participant_breakdown,
    :local_network_participants_withdrawn,
    :local_network_recent_cops,
    :local_network_recent_logo_requests,
    :local_network_recently_delisted,
    :local_network_recently_noncommunicating,
    :local_network_upcoming_cops,
    :local_network_upcoming_delistings,
    :local_network_upcoming_sme_delistings,
    :local_networks_contacts,
    :networks,
    :participant_breakdown,
    :published_webpages,
  ]

  XlsReports = [
    :delisted_participants,
    :participant_breakdown,
    :participant_applications,
    :contacts_mail_merge,
    :contacts_excel_macro,
    :all_cops,
    :all_logo_requests,
    :approved_logo_requests,
    :listed_companies,
    :local_networks_management,
    :local_networks_knowledge_sharing,
    :local_networks_contacts,
    :local_networks_all_contacts,
    :local_networks_report_recipients,
    :local_networks_events,
    :local_network_participant_breakdown,
    :local_network_participant_contacts,
    :local_network_delisted_participants,
    :local_network_all_cops,
    :local_network_recent_cops,
    :local_network_upcoming_cops,
    :local_network_upcoming_delistings,
    :local_network_upcoming_sme_delistings,
    :local_network_recently_noncommunicating,
    :local_network_recently_delisted,
    :local_network_recent_logo_requests,
    :local_network_participants_withdrawn,
    :initiative_contacts,
    :initiative_contacts2,
    :initiative_organizations,
    :cop_questionnaire_answers,
    :cop_required_elements,
    :cops_with_differentiation,
    :cop_languages,
    :cop_lead_submissions,
    :cop_water_mandate_submissions,
    # :networks, # FIXME
    :foundation_pledges,
    :published_webpages,
  ]

  context "given a staff user" do
    setup do
      create_ungc_organization_and_user
      create_removal_reason(description: RemovalReason::FILTERS[:requested])

      sign_in @staff_user
    end

    should "get the index page" do
      get :index, {}
      assert_response :success
    end

    HtmlReports.each do |report_name|
      should "get the #{report_name} report" do
        get report_name, {}
        assert_response :success
        assert_template report_name
      end
    end

    XlsReports.each do |report_name|
      should "get the #{report_name} report as xls" do
        get report_name, {format: 'xls'}
        assert_response :success
        assert_equal 'application/vnd.ms-excel', @response.headers['Content-Type']
      end
    end

    context "initiatives reports" do
      setup do
        @organization       = create_organization
        @organization2      = create_organization
        @climate_initiative = create_initiative(:name => 'Caring for Climate')
        @water_initiative   = create_initiative(:name => 'CEO Water Mandate')
        @peace_initiative   = create_initiative(:name => 'Business for Peace')
        @climate_initiative.signings.create [ { :signatory => @organization },
                                             { :signatory => @organization2 } ]
      end

      should "get the report for all initiatives" do
        get :initiative_organizations, all_initiatives: true
        assert_not_nil assigns(:report)
        assert_not_nil assigns(:selected_initiatives)
        assert_template 'initiative_organizations'
      end

      should "get the report for selected initiatives" do
        get :initiative_organizations, initiatives: [@climate_initiative.id]
        assert_not_nil assigns(:report)
        assert_not_nil assigns(:selected_initiatives)
        assert_template 'initiative_organizations'
      end

    end

  end
end
