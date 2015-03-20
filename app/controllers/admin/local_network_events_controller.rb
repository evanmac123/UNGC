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
    params.require(:local_network_event).permit(
      :event_type,
      :date,
      :title,
      :description,
      :stakeholder_company,
      :stakeholder_sme,
      :stakeholder_labour,
      :stakeholder_business_association,
      :stakeholder_ngo,
      :stakeholder_academic,
      :stakeholder_foundation,
      :stakeholder_government,
      :stakeholder_media,
      :stakeholder_un_agency,
      :num_participants,
      :gc_participant_percentage,
      principle_ids: [],
      uploaded_attachments: [
        :attachment,
        :attachable_type
      ]
    )
  end
end


