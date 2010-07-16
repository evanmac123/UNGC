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
  
  def companies_without_contacts
    @report = SimpleOrganizationReport.new
    render_formatter(filename: "companies_without_contacts_#{date_as_filename}.xls")
  end
  
  def local_networks_contacts
    @report = LocalNetworksContacts.new
    render_formatter(filename: "local_networks_contacts_#{date_as_filename}.xls")
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
        format.xls  { send_data @report.render_xls, :type     => 'application/ms-excel',
                                                    :filename => options[:filename] }
      end
    end

    def date_as_filename
      [Date.today.year, Date.today.month, Date.today.day].join('_')
    end

end
