class Admin::ReportsController < AdminController

  def participant_breakdown
    @report = ParticipantBreakdownReport.new
    render_formatter(filename: "participant_breakdown_#{date_as_filename}.csv")
  end
  
  def approved_logo_requests
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year
    
    @report = ApprovedLogoRequestsReport.new(:month => @month,
                                             :year  => @year)
    render_formatter(filename: "approved_logo_requests_#{date_as_filename}.csv")
  end
  
  def listed_companies
    @report = ListedCompaniesReport.new
    render_formatter(filename: "listed_companies_#{date_as_filename}.csv")
  end

  def bulletin_subscribers
    @report = BulletinSubscribersReport.new
    render_formatter(filename: "bulletin_subscribers_#{date_as_filename}.csv")
  end
  
  def companies_without_contacts
    @report = SimpleOrganizationReport.new
    render_formatter(filename: "companies_without_contract_#{date_as_filename}.csv")
  end
  
  def networks
    @regions = Country.regions
    @region = params[:region] || @regions.first.region
    @countries = Country.where_region @region
    @country = params[:country]
    
    @report = NetworksReport.new(:region  => @region,
                                 :country => @country)
    render_formatter(filename: "networks_report_#{date_as_filename}.csv")
  end
  
  def foundation_pledges
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year
    
    @report = FoundationPledgeReport.new(:month => @month,
                                         :year  => @year)
    render_formatter(filename: "foundation_pledges_#{date_as_filename}.csv")
  end
  
  private
    def render_formatter(options={})
      respond_to do |format|
        format.html
        format.csv  { send_data @report.render_csv, :type     => 'application/ms-excel',
                                                    :filename => options[:filename] }
      end
    end

    def date_as_filename
      [Date.today.month, Date.today.day, Date.today.year].join('.')
    end

end
