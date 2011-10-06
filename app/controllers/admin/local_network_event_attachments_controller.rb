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
    "Back to Events"
  end

  def cancel_path
    knowledge_sharing_path(@model, :tab => 'local_network_events')
  end

  def knowledge_sharing_tab?
    true
  end
end
