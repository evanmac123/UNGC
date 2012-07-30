class Admin::ReportsController < AdminController

  def delisted_participants
    @report = DelistedParticipants.new
    render_formatter(filename: "delisted_participants_#{date_as_filename}.xls")
  end

  def participant_breakdown
    @report = ParticipantBreakdownReport.new
    render_formatter(filename: "participant_breakdown_#{date_as_filename}.xls")
  end

  def contacts_mail_merge
    @report = ContactsMailMerge.new
    render_formatter(filename: "contacts_mail_merge_#{date_as_filename}.xls")
  end

  def contacts_excel_macro
    @report = ContactsExcelMacro.new
    render_formatter(filename: "contacts_excel_macro_#{date_as_filename}.xls")
  end

  def all_cops
    @report = AllCops.new
    render_formatter(filename: "all_cops_#{date_as_filename}.xls")
  end

  def approved_logo_requests
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year

    @report = ApprovedLogoRequestsReport.new(:month => @month,
                                             :year  => @year)
    render_formatter(filename: "approved_logo_requests_#{date_as_filename}.xls")
  end

  def listed_companies
    @report = ListedCompaniesReport.new
    render_formatter(filename: "listed_companies_#{date_as_filename}.xls")
  end

  def bulletin_subscribers
    @report = BulletinSubscribersReport.new
    render_formatter(filename: "bulletin_subscribers_#{date_as_filename}.xls")
  end

  def local_networks_management
    @report = LocalNetworksManagement.new
    render_formatter(filename: "local_networks_management_#{date_as_filename}.xls")
  end

  def local_networks_knowledge_sharing
    @report = LocalNetworksKnowledgeSharing.new
    render_formatter(filename: "local_networks_knowledge_sharing_#{date_as_filename}.xls")
  end

  def local_networks_contacts
    @report = LocalNetworksContacts.new
    render_formatter(filename: "local_networks_contacts_#{date_as_filename}.xls")
  end

  def local_networks_report_recipients
    @report = LocalNetworksReportRecipients.new
    render_formatter(filename: "local_networks_report_recipients_#{date_as_filename}.xls")
  end

  def local_networks_events
    @report = LocalNetworksEvents.new
    render_formatter(filename: "local_networks_events_#{date_as_filename}.xls")
  end

  def initiative_contacts
    @report = InitiativeContacts.new
    render_formatter(filename: "water_mandate_contacts_#{date_as_filename}.xls")
  end

  def cop_questionnaire_answers
    @report = CopQuestionnaireAnswers.new
    render_formatter(filename: "cop_questionnaire_answers_#{date_as_filename}.xls")
  end

  def cop_required_elements
    @report = CopRequiredElements.new
    render_formatter(filename: "cop_required_elements_#{date_as_filename}.xls")
  end

  def cops_with_differentiation
    @report = CopsWithDifferentiation.new
    render_formatter(filename: "cops_with_differentiation_#{date_as_filename}.xls")
  end

  def cop_languages
    @report = CopLanguages.new
    render_formatter(filename: "cop_file_languages_#{date_as_filename}.xls")
  end

  def cop_lead_submissions
    @report = CopLeadSubmissions.new
    render_formatter(filename: "cop_lead_submissions_#{date_as_filename}.xls")
  end

  def networks
    @regions = Country.regions
    @region = params[:region] || @regions.first.region
    @countries = Country.where_region @region
    @country = params[:country]

    @report = NetworksReport.new(:region  => @region,
                                 :country => @country)
    render_formatter(filename: "networks_report_#{date_as_filename}.xls")
  end

  def foundation_pledges
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year

    @report = FoundationPledgeReport.new(:month => @month,
                                         :year  => @year)
    render_formatter(filename: "foundation_pledges_#{@year}_#{@month}.xls")
  end

  private
    def render_formatter(options={})

      respond_to do |format|
        format.html
        format.xls  { send_data @report.render_output, :type     => 'application/ms-excel',
                                                       :filename => options[:filename] }
      end
    end

    def date_as_filename
      Date.today.iso8601.gsub('-', '_')
    end

end
