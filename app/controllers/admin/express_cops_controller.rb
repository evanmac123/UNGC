class Admin::ExpressCopsController < AdminController
  before_filter :no_unapproved_organizations_access
  before_filter :redirect_unless_sme, except: :show

  def show
    cop = ExpressCop.find(params.fetch(:id))
    @communication = CopPresenter.new(cop, current_contact)
    render '/admin/cops/show'
  end

  def new
    @organization = organization
    @cop = ExpressCop.new(organization: @organization)
  end

  def create
    @organization = organization
    @cop = build_cop
    if @cop.save
      redirect_to admin_express_cop_path(@cop),
        notice: I18n.t('notice.cop_published')
    else
      render :new
    end
  end

  private

  def organization
    @_organization ||= Organization.find(params.fetch(:organization_id))
  end

  def redirect_unless_sme
    if organization.organization_type != OrganizationType.sme
      redirect_to cop_introduction_url, notice: I18n.t('notice.only_sme')
    end
  end

  def cop_params
    params.fetch(:express_cop, {}).permit(
      :endorses_ten_principles,
      :covers_issue_areas,
      :measures_outcomes
    )
  end

  def build_cop
    ExpressCop.new(cop_params.merge(
      organization: organization,
      contact_info: current_contact.contact_info
    ))
  end

end
