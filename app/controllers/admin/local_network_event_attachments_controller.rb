class Admin::LocalNetworkEventAttachmentsController < Admin::AttachmentsController
  before_filter :load_local_network
  before_filter :no_access_to_other_local_networks, :except => [:show]

  private

  def load_local_network
    @local_network = @submodel.local_network
  end

  def model
    LocalNetwork
  end

  def submodel
    LocalNetworkEvent
  end

  def header_string
    "Upload Files"
  end

  def cancel_string
    "Back to Event Details"
  end

  def cancel_path
    edit_admin_local_network_local_network_event_path(@submodel.local_network, @submodel, :tab => :files)
  end

  def knowledge_sharing_tab?
    true
  end
end
