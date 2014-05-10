class Admin::CopFilesController < Admin::AttachmentsController
  before_filter :load_organization
  before_filter :no_unapproved_organizations_access

  private

  def load_organization
    @organization = @submodel.organization
  end

  def model
    Organization
  end

  def submodel
    CommunicationOnProgress
  end

  def cancel_string
    "Back to #{@organization.cop_acronym} details"
  end

  def cancel_path
    admin_organization_communication_on_progress_path(@organization.id, @submodel, tab: 'results')
    # edit_admin_organization_communication_on_progress_path(@organization.id, @submodel.id, tab: :files)
  end

  def attachments
    @submodel.cop_files
  end

end