module Admin::SponsorsHelper
  def paged_sponsors
    @paged_sponsors ||= Sponsor.paginate(:page => (params[:page] || 1),
                                     :order => order_from_params)
  end
end
