module Admin::ContributionDescriptionsHelper
  def show_pledge_description?(contribution_description)
    contribution_description.pledge_continued.present? ? 'display: block;' : 'display: none;'
  end
end
