class Redesign::CopsController < Redesign::ApplicationController

  def active
  end
  def advanced
  end
  def expelled
  end
  def learner
  end
  def non_communicating
  end
  def submitted_coe
  end

  def show
    if load_communication_on_progress
      redirect_mismatched_differentiation_urls
      determine_navigation
      @communication = CommunicationPresenter.create(@communication_on_progress, current_contact)
    else
      redirect_to DEFAULTS[:cop_path] # FIXME: Should redirect to search?
    end
  end

  def feed
    @cops_for_feed = CommunicationOnProgress.approved.for_feed

    respond_to do |format|
      format.atom { render :layout => false }
    end
  end

  private

    def load_communication_on_progress
      @communication_on_progress = find_cop_by_id || find_cop_by_cop_and_org
    end

    def find_cop_by_id
      CommunicationOnProgress.find_by_id(params[:id])
    end

    def find_cop_by_cop_and_org
      @organization = Organization.find_by_param(params[:organization])
      @organization.communication_on_progresses.find_by_param(params[:cop]) if @organization
    end

    def redirect_mismatched_differentiation_urls
      nav = params[:navigation]
      differentiation = @communication_on_progress.differentiation
      if nav.present? &&
          differentiation.present? &&
          nav != differentiation
        redirect_to cop_detail_with_nav_url(differentiation, @communication_on_progress.id),
          status: :moved_permanently
      end
    end

end
