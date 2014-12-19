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

    should "get the approved logo request report" do
      get :approved_logo_requests, {}
      assert_response :success
      assert_template 'approved_logo_requests'
    end

    should "get the approved logo request report as xls" do
      get :approved_logo_requests, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the listed companies report" do
      get :listed_companies, {}
      assert_response :success
      assert_template 'listed_companies'
    end

    should "get the listed companies report as xls" do
      get :listed_companies, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    # should "get the networks report" do
    #      create_country
    #      get :networks, {}
    #      assert_response :success
    #      assert_template 'networks'
    #    end
    #
    #    should "get the networks report as xls" do
    #      create_country
    #      get :networks, {:format => 'xls'}
    #      assert_response :success
    #      assert_equal @response.headers['Content-Type'], xls_mime_type
    #    end

    should "get the foundation pledges report" do
      get :foundation_pledges, {}
      assert_response :success
      assert_template 'foundation_pledges'
    end

    should "get the foundation pledges report as xls" do
      get :foundation_pledges, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the participant breakdown report" do
      get :participant_breakdown, {}
      assert_response :success
      assert_template 'participant_breakdown'
    end

    should "get the participant breakdown report as xls" do
      get :participant_breakdown, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the contacts for mail merge report" do
      get :contacts_mail_merge, {}
      assert_response :success
      assert_template 'contacts_mail_merge'
    end

    should "get the contacts for mail merge report as xls" do
      get :contacts_mail_merge, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
    end

    should "get the local networks contacts report" do
      get :local_networks_contacts, {}
      assert_response :success
      assert_template 'local_networks_contacts'
    end

    should "get the local networks contacts report as xls" do
      get :local_networks_contacts, {:format => 'xls'}
      assert_response :success
      assert_excel_content_type
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
        assert_excel_content_type
      end
    end

    context "given the initiatives report" do
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

  def assert_excel_content_type
    assert_equal 'application/vnd.ms-excel; charset=utf-8', @response.headers['Content-Type']
  end

end
