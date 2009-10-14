class ReportsController < ApplicationController
  layout 'admin'

  def approved_logo_requests
    @records = LogoRequest.approved.all(:limit => 20)
    @formatter = LogoRequestFormatter.new
    render_formatter
  end
  
  def listed_companies
    @records = Organization.listed.all(:limit => 20, :include => [:country, :exchange])
    @formatter = ListedCompaniesFormatter.new
    render_formatter
  end
  
  def companies_without_contacts
    @records = Organization.without_contacts.all(:limit => 10)
    @formatter = SimpleOrganizationFormatter.new
    render_formatter
  end
  
  private
    def render_formatter
      respond_to do |format|
        format.html
        format.csv  { send_data @formatter.render_csv(@records), :type        => 'application/ms-excel',
                                                                 :disposition => 'inline' }
      end
    end
end
