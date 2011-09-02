class Admin::MousController < Admin::LocalNetworkSubmodelController
  def submodel
    MOU
  end

  def show
    file = @submodel.file
    send_file file.full_filename, :type => file.content_type, :disposition => 'inline'
  end
end

