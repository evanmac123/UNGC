class ReportsController < ApplicationController
  layout 'admin'

  def approved_logo_requests
    @month = params[:month] || Date.today.month
    @year = params[:year] || Date.today.year
    
    @records = LogoRequest.approved.submitted_in(@month.to_i, @year.to_i).all(:limit => 20)
    @formatter = LogoRequestFormatter.new
    render_formatter(filename: "approved_logo_requests_#{date_as_filename}.csv")
  end
  
  def listed_companies
    @records = Organization.listed.all(:limit => 20, :include => [:country, :exchange])
    @formatter = ListedCompaniesFormatter.new
    render_formatter(filename: "listed_companies_#{date_as_filename}.csv")
  end
  
  def companies_without_contacts
    @records = Organization.without_contacts.all(:limit => 10)
    @formatter = SimpleOrganizationFormatter.new
    render_formatter(filename: "companies_without_contract_#{date_as_filename}.csv")
  end
  
  private
    def render_formatter(options={})
      respond_to do |format|
        format.html
        format.csv  { send_data @formatter.render_csv(@records), :type        => 'application/ms-excel',
                                                                 :filename    => options[:filename],
                                                                 :disposition => 'inline' }
      end
    end

    def date_as_filename
      [Date.today.month, Date.today.day, Date.today.year].join('.')
    end
end
