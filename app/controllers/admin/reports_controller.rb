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
    render_report(DelistedParticipants.new)
  end

  def participant_breakdown
    render_report(ParticipantBreakdownReport.new)
  end

  def participant_applications
    render_report(ParticipantApplications.new)
  end

  def contacts_mail_merge
    render_report(ContactsMailMerge.new)
  end

  def contacts_excel_macro
    render_report(ContactsExcelMacro.new)
  end

  def all_cops
    render_report(AllCops.new)
  end

  def all_logo_requests
    render_report(AllLogoRequests.new)
  end

  def approved_logo_requests
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year

    render_report(ApprovedLogoRequestsReport.new(month: @month, year: @year))
  end

  def listed_companies
    render_report(ListedCompaniesReport.new)
  end

  def local_networks_management
    render_report(LocalNetworksManagement.new)
  end

  def local_networks_knowledge_sharing
    render_report(LocalNetworksKnowledgeSharing.new)
  end

  def local_networks_contacts
    render_report(LocalNetworksContacts.new)
  end

  def local_networks_all_contacts
    render_report(LocalNetworksAllContacts.new)
  end

  def local_networks_report_recipients
    render_report(LocalNetworksReportRecipients.new)
  end

  def local_networks_events
    render_report(LocalNetworksEvents.new)
  end

  def local_network_participant_breakdown
    render_report(LocalNetworkParticipantBreakdown.new(user))
  end

  def local_network_participant_contacts
    render_report(LocalNetworkParticipantContacts.new(user))
  end

  def local_network_delisted_participants
    render_report(LocalNetworkDelistedParticipants.new(user))
  end

  def local_network_all_cops
    render_report(LocalNetworkAllCops.new(user))
  end

  def local_network_recent_cops
    render_report(LocalNetworkRecentCops.new(user))
  end

  def local_network_upcoming_cops
    render_report(LocalNetworkUpcomingCops.new(user))
  end

  def local_network_upcoming_delistings
    render_report(LocalNetworkUpcomingDelistings.new(user))
  end

  def local_network_upcoming_sme_delistings
    render_report(LocalNetworkUpcomingSmeDelistings.new(user))
  end

  def local_network_recently_noncommunicating
    render_report(LocalNetworkRecentlyNoncommunicating.new(user))
  end

  def local_network_recently_delisted
    render_report(LocalNetworkRecentlyDelisted.new(user))
  end

  def local_network_recent_logo_requests
    render_report(LocalNetworkRecentLogoRequests.new(user))
  end

  def local_network_participants_withdrawn
    render_report(LocalNetworkParticipantsWithdrawn.new(user))
  end

  def initiative_contacts
    render_report(InitiativeContacts.new)
  end

  def initiative_contacts2
    render_report(InitiativeContacts2.new)
  end

  def initiative_organizations
    if params[:all_initiatives]
      @selected_initiatives = Initiative.for_select.map(&:id)
    else
      @selected_initiatives = params[:initiatives] || []
    end

    render_report(InitiativeOrganizations.new(initiatives: @selected_initiatives))
  end

  def cop_questionnaire_answers
    render_report(CopQuestionnaireAnswers.new)
  end

  def cop_required_elements
    render_report(CopRequiredElements.new)
  end

  def cops_with_differentiation
    render_report(CopsWithDifferentiation.new)
  end

  def cop_languages
    render_report(CopLanguages.new)
  end

  def cop_lead_submissions
    render_report(CopLeadSubmissions.new)
  end

  def cop_water_mandate_submissions
    render_report(CopWaterMandateSubmissions.new)
  end

  def networks
    @regions = Country.regions
    @region = params[:region] || @regions.first.region
    @countries = Country.where_region @region
    @country = params[:country]

    report = NetworksReport.new(:region  => @region,
                                :country => @country)
    render_report(report)
  end

  def foundation_pledges
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year

    report = FoundationPledgeReport.new(:month => @month,
                                         :year  => @year)
    render_report(report)
  end

  def published_webpages
    render_report(PublishedWebpages.new)
  end

  private

  def user
    {contact_id:  current_contact.id}
  end

  def render_report(report)
    @report = report
    respond_to do |format|
      format.html
      format.xls  {
        status = ReportWorker.generate_xls(@report)
        render json: status
      }
    end
  end

end
