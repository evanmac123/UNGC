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
    report = DelistedParticipants.new
    render_report(report, "delisted_participants_#{date_as_filename}.xls")
  end

  def participant_breakdown
    report = ParticipantBreakdownReport.new
    render_report(report, "participant_breakdown_#{date_as_filename}.xls")
  end

  def participant_applications
    report = ParticipantApplications.new
    render_report(report, "participant_applications_#{date_as_filename}.xls")
  end

  def contacts_mail_merge
    report = ContactsMailMerge.new
    render_report(report, "contacts_mail_merge_#{date_as_filename}.xls")
  end

  def contacts_excel_macro
    report = ContactsExcelMacro.new
    render_report(report, "contacts_excel_macro_#{date_as_filename}.xls")
  end

  def all_cops
    report = AllCops.new
    render_report(report, "all_cops_#{date_as_filename}.xls")
  end

  def all_logo_requests
    report = AllLogoRequests.new
    render_report(report, "all_logo_requests_#{date_as_filename}.xls")
  end

  def approved_logo_requests
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year

    report = ApprovedLogoRequestsReport.new(month: @month, year: @year)
    render_report(report, "approved_logo_requests_#{date_as_filename}.xls")
  end

  def sdg_pioneer_submission
    report = SdgPioneerSubmissionReport.new
    render_report(report, "sdg_pioneer_submission_#{date_as_filename}.xls")
  end

  def sdg_pioneer_other
    report = SdgPioneerOtherReport.new
    render_report(report, "sdg_pioneer_other_#{date_as_filename}.xls")
  end

  def listed_companies
    report = ListedCompaniesReport.new
    render_report(report, "listed_companies_#{date_as_filename}.xls")
  end

  def local_networks_management
    report = LocalNetworksManagement.new
    render_report(report, "local_networks_management_#{date_as_filename}.xls")
  end

  def local_networks_knowledge_sharing
    report = LocalNetworksKnowledgeSharing.new
    render_report(report, "local_networks_knowledge_sharing_#{date_as_filename}.xls")
  end

  def local_networks_contacts
    report = LocalNetworksContacts.new
    render_report(report, "local_networks_contacts_#{date_as_filename}.xls")
  end

  def local_networks_all_contacts
    report = LocalNetworksAllContacts.new
    render_report(report, "local_networks_all_contacts_#{date_as_filename}.xls")
  end

  def local_networks_events
    report = LocalNetworksEvents.new
    render_report(report, "local_networks_events_#{date_as_filename}.xls")
  end

  def local_network_participant_breakdown
    report = LocalNetworkParticipantBreakdown.new(contact_id)
    render_report(report, "local_network_participant_breakdown_#{date_as_filename}.xls")
  end

  def local_network_participant_contacts
    report = LocalNetworkParticipantContacts.new(contact_id)
    render_report(report, "local_network_participant_contacts_#{date_as_filename}.xls")
  end

  def local_network_delisted_participants
    report = LocalNetworkDelistedParticipants.new(contact_id)
    render_report(report, "local_network_delisted_participants_#{date_as_filename}.xls")
  end

  def local_network_all_cops
    report = LocalNetworkAllCops.new(contact_id)
    render_report(report, "local_network_all_cops_#{date_as_filename}.xls")
  end

  def local_network_recent_cops
    report = LocalNetworkRecentCops.new(contact_id)
    render_report(report, "local_network_recent_cops_#{date_as_filename}.xls")
  end

  def local_network_upcoming_cops
    report = LocalNetworkUpcomingCops.new(contact_id)
    render_report(report, "local_network_upcoming_cops_#{date_as_filename}.xls")
  end

  def local_network_upcoming_delistings
    report = LocalNetworkUpcomingDelistings.new(contact_id)
    render_report(report, "local_network_upcoming_delistings_#{date_as_filename}.xls")
  end

  def local_network_recently_noncommunicating
    report = LocalNetworkRecentlyNoncommunicating.new(contact_id)
    render_report(report, "local_network_recently_noncommunicating_#{date_as_filename}.xls")
  end

  def local_network_recently_delisted
    report = LocalNetworkRecentlyDelisted.new(contact_id)
    render_report(report, "local_network_recently_delisted_#{date_as_filename}.xls")
  end

  def local_network_recent_logo_requests
    report = LocalNetworkRecentLogoRequests.new(contact_id)
    render_report(report, "local_network_recent_logo_requests_#{date_as_filename}.xls")
  end

  def local_network_participants_withdrawn
    report = LocalNetworkParticipantsWithdrawn.new(contact_id)
    render_report(report, "local_network_participants_withdrawn_#{date_as_filename}.xls")
  end

  def initiative_contacts
    report = InitiativeContacts.new
    render_report(report, "water_mandate_contacts_#{date_as_filename}.xls")
  end

  def initiative_contacts2
    report = InitiativeContacts2.new
    render_report(report, "caring_for_climate_contacts_#{date_as_filename}.xls")
  end

  def initiative_organizations
    if params[:all_initiatives]
      @selected_initiatives = Initiative.all.map(&:id)
    else
      @selected_initiatives = params[:initiatives] || []
    end

    report = InitiativeOrganizations.new(initiatives: @selected_initiatives)
    render_report(report, "organizations_in_initiatives_#{date_as_filename}.xls")
  end

  def cop_questionnaire_answers
    report = CopQuestionnaireAnswers.new
    render_report(report, "cop_questionnaire_answers_#{date_as_filename}.xls")
  end

  def cop_required_elements
    report = CopRequiredElements.new
    render_report(report, "cop_required_elements_#{date_as_filename}.xls")
  end

  def cops_with_differentiation
    report = CopsWithDifferentiation.new
    render_report(report, "cops_with_differentiation_#{date_as_filename}.xls")
  end

  def cop_languages
    report = CopLanguages.new
    render_report(report, "cop_file_languages_#{date_as_filename}.xls")
  end

  def cop_lead_submissions
    report = CopLeadSubmissions.new
    render_report(report, "cop_lead_submissions_#{date_as_filename}.xls")
  end

  def cop_water_mandate_submissions
    report = CopWaterMandateSubmissions.new
    render_report(report, "cop_water_mandate_submissions_#{date_as_filename}.xls")
  end

  def networks
    @regions = Country.regions
    @region = params[:region] || @regions.first.region
    @countries = Country.where_region @region
    @country = params[:country]

    report = NetworksReport.new(:region  => @region,
                                :country => @country)
    render_report(report, "networks_report_#{date_as_filename}.xls")
  end

  def foundation_pledges
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year

    report = FoundationPledgeReport.new(:month => @month,
                                         :year  => @year)
    render_report(report, "foundation_pledges_#{@year}_#{@month}.xls")
  end

  private

  def contact_id
    {contact_id:  current_contact.id}
  end

  def render_report(report, filename)
    respond_to do |format|
      format.html { @report = report }
      format.xls  {
        status = ReportWorker.generate_xls(report, filename)
        render json: status
      }
    end
  end

  def date_as_filename
    Date.today.iso8601.gsub('-', '_')
  end

end
