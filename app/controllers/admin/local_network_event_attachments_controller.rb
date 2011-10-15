class Admin::LocalNetworkEventAttachmentsController < Admin::AttachmentsController
  private

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
