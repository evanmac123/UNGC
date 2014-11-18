class Admin::LocalNetworkEventsController < Admin::LocalNetworkSubmodelController
  before_filter :no_access_to_other_local_networks, :except => [:show]

  def show
  end

  private

  def submodel
    LocalNetworkEvent
  end

  def submodel_association_method
    'events'
  end

  def return_url
    knowledge_sharing_path(@local_network, :tab => @tab)
  end

  def submodel_params
    event_params = params.require(:local_network_event).permit(
      :title,
      :description,
      :event_type,
      :date,
      :num_participants,
      :gc_participant_percentage,
      :attachments => [:attachment, :attachable_type]
    )

    # the controller expects attachments to be an array of UploadedFiles, not params
    # TODO convert this to nested_attributes or specialize the create method
    event_params[:attachments] = event_params[:attachments].map do |attachment_params|
      UploadedFile.new(attachment_params)
    end

    event_params
  end
end


