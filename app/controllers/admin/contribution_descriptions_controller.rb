class Admin::ContributionDescriptionsController < Admin::LocalNetworkSubmodelController
  def submodel
    ContributionDescription
  end

  private

  def build_submodel
    @submodel = @local_network.contribution_description || @local_network.build_contribution_description
  end

  def submodel_association_method
    submodel.name.underscore
  end

  def load_submodel
    @submodel = @local_network.contribution_description
  end
end
