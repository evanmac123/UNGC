class ReportsController < ApplicationController
  layout 'admin'

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
  
  def companies_without_contacts
    @report = SimpleOrganizationReport.new
    render_formatter(filename: "companies_without_contract_#{date_as_filename}.csv")
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
