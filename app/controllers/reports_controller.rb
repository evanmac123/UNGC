class ReportsController < ApplicationController
  layout 'admin'
  
  def approved_logo_requests
    @records = LogoRequest.approved.all(:limit => 50)
    @formatter = LogoRequestFormatter.new

    respond_to do |format|
      format.html
      format.csv  { send_data @formatter.render_csv(@records), :type        => 'application/ms-excel',
                                                               :disposition => 'inline' }
    end
  end  
end
