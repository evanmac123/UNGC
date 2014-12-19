class Admin::ReportsController < AdminController

  def index
    local_network = current_contact.local_network
    render case
    when local_network.nil?
      :index
    when local_network.regional_center?
      :regional_center_index
    else
      :local_network_index
    end
  end

  def status
    status = ReportStatus.find(params[:id])
    render json: status
  end

  def download
    status = ReportStatus.find(params[:id])
    send_file status.path, filename: status.filename
  end

  def delisted_participants
    @report = DelistedParticipants.new
    render_formatter filename: "delisted_participants_#{date_as_filename}.xls"
  end

  def participant_breakdown
    @report = ParticipantBreakdownReport.new
    render_formatter filename: "participant_breakdown_#{date_as_filename}.xls"
  end

  def participant_applications
    @report = ParticipantApplications.new
    render_formatter filename: "participant_applications_#{date_as_filename}.xls"
  end

  def contacts_mail_merge
    @report = ContactsMailMerge.new
    render_formatter filename: "contacts_mail_merge_#{date_as_filename}.xls"
  end

  def contacts_excel_macro
    @report = ContactsExcelMacro.new
    render_formatter filename: "contacts_excel_macro_#{date_as_filename}.xls"
  end

  def all_cops
    @report = AllCops.new
    render_formatter filename: "all_cops_#{date_as_filename}.xls"
  end

  def all_logo_requests
    @report = AllLogoRequests.new
    render_formatter filename: "all_logo_requests_#{date_as_filename}.xls"
  end

  def approved_logo_requests
    @month  = params[:month] || Date.today.month
    @year   = params[:year] || Date.today.year
    @report = ApprovedLogoRequestsReport.new(month: @month, year: @year)

    render_formatter filename: "approved_logo_requests_#{date_as_filename}.xls"
  end

  def listed_companies
    @report = ListedCompaniesReport.new
    render_formatter filename: "listed_companies_#{date_as_filename}.xls"
  end

  def local_networks_management
    @report = LocalNetworksManagement.new
    render_formatter filename: "local_networks_management_#{date_as_filename}.xls"
  end

  def local_networks_knowledge_sharing
    @report = LocalNetworksKnowledgeSharing.new
    render_formatter filename: "local_networks_knowledge_sharing_#{date_as_filename}.xls"
  end

  def local_networks_contacts
    @report = LocalNetworksContacts.new
    render_formatter filename: "local_networks_contacts_#{date_as_filename}.xls"
  end

  def local_networks_all_contacts
    @report = LocalNetworksAllContacts.new
    render_formatter filename: "local_networks_all_contacts_#{date_as_filename}.xls"
  end

  def local_networks_report_recipients
    @report = LocalNetworksReportRecipients.new
    render_formatter filename: "local_networks_report_recipients_#{date_as_filename}.xls"
  end

  def local_networks_events
    @report = LocalNetworksEvents.new
    render_formatter filename: "local_networks_events_#{date_as_filename}.xls"
  end

  def local_network_participant_breakdown
    @report = LocalNetworkParticipantBreakdown.new(default_report_params)
    render_formatter filename: "local_network_participant_breakdown_#{date_as_filename}.xls"
  end

  def local_network_participant_contacts
    @report = LocalNetworkParticipantContacts.new(default_report_params)
    render_formatter filename: "local_network_participant_contacts_#{date_as_filename}.xls"
  end

  def local_network_delisted_participants
    @report = LocalNetworkDelistedParticipants.new(default_report_params)
    render_formatter filename: "local_network_delisted_participants_#{date_as_filename}.xls"
  end

  def local_network_all_cops
    @report = LocalNetworkAllCops.new(default_report_params)
    render_formatter filename: "local_network_all_cops_#{date_as_filename}.xls"
  end

  def local_network_recent_cops
    @report = LocalNetworkRecentCops.new(default_report_params)
    render_formatter filename: "local_network_recent_cops_#{date_as_filename}.xls"
  end

  def local_network_upcoming_cops
    @report = LocalNetworkUpcomingCops.new(default_report_params)
    render_formatter filename: "local_network_upcoming_cops_#{date_as_filename}.xls"
  end

  def local_network_upcoming_delistings
    @report = LocalNetworkUpcomingDelistings.new(default_report_params)
    render_formatter filename: "local_network_upcoming_delistings_#{date_as_filename}.xls"
  end

  def local_network_upcoming_sme_delistings
    @report = LocalNetworkUpcomingSmeDelistings.new(default_report_params)
    render_formatter filename: "local_network_upcoming_sme_delistings_#{date_as_filename}.xls"
  end

  def local_network_recently_noncommunicating
    @report = LocalNetworkRecentlyNoncommunicating.new(default_report_params)
    render_formatter filename: "local_network_recently_noncommunicating_#{date_as_filename}.xls"
  end

  def local_network_recently_delisted
    @report = LocalNetworkRecentlyDelisted.new(default_report_params)
    render_formatter filename: "local_network_recently_delisted_#{date_as_filename}.xls"
  end

  def local_network_recent_logo_requests
    @report = LocalNetworkRecentLogoRequests.new(default_report_params)
    render_formatter filename: "local_network_recent_logo_requests_#{date_as_filename}.xls"
  end

  def local_network_participants_withdrawn
    @report = LocalNetworkParticipantsWithdrawn.new(default_report_params)
    render_formatter filename: "local_network_participants_withdrawn_#{date_as_filename}.xls"
  end

  def initiative_contacts
    @report = InitiativeContacts.new
    render_formatter filename: "water_mandate_contacts_#{date_as_filename}.xls"
  end

  def initiative_contacts2
    @report = InitiativeContacts2.new
    render_formatter filename: "caring_for_climate_contacts_#{date_as_filename}.xls"
  end

  def initiative_organizations
    @selected_initiatives = if params[:all_initiatives]
      Initiative.for_select.map(&:id)
    else
      params[:initiatives] || []
    end

    @report = InitiativeOrganizations.new(initiatives: @selected_initiatives)

    render_formatter filename: "organizations_in_initiatives_#{date_as_filename}.xls"
  end

  def cop_questionnaire_answers
    @report = CopQuestionnaireAnswers.new
    render_formatter filename: "cop_questionnaire_answers_#{date_as_filename}.xls"
  end

  def cop_required_elements
    @report = CopRequiredElements.new
    render_formatter filename: "cop_required_elements_#{date_as_filename}.xls"
  end

  def cops_with_differentiation
    @report = CopsWithDifferentiation.new
    render_formatter filename: "cops_with_differentiation_#{date_as_filename}.xls"
  end

  def cop_languages
    @report = CopLanguages.new
    render_formatter filename: "cop_file_languages_#{date_as_filename}.xls"
  end

  def cop_lead_submissions
    @report = CopLeadSubmissions.new
    render_formatter filename: "cop_lead_submissions_#{date_as_filename}.xls"
  end

  def cop_water_mandate_submissions
    @report = CopWaterMandateSubmissions.new
    render_formatter filename: "cop_water_mandate_submissions_#{date_as_filename}.xls"
  end

  def networks
    @regions   = Country.regions
    @region    = params[:region] || @regions.first.region
    @countries = Country.where_region(@region)
    @country   = params[:country]
    @report    = NetworksReport.new(region: @region, country: @country)

    render_formatter filename: "networks_report_#{date_as_filename}.xls"
  end

  def foundation_pledges
    @month  = params[:month] || Date.today.month
    @year   = params[:year] || Date.today.year
    @report = FoundationPledgeReport.new(month: @month, year: @year)

    render_formatter filename: "foundation_pledges_#{@year}_#{@month}.xls"
  end

  def published_webpages
    @report = PublishedWebpages.new
    render_formatter filename: "published_webpages_#{date_as_filename}.xls"
  end

  private

  def default_report_params
    { user: current_contact }
  end

  def render_formatter(options={})
    respond_to do |format|
      format.html
      format.xls {
        send_file(@report.render_output,
          filename: options[:filename],
          type: 'application/vnd.ms-excel; charset=utf-8'
        )
      }
    end
  end

  def date_as_filename
    Date.today.iso8601.gsub('-', '_')
  end

end
