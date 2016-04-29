class SdgPioneer::OthersController < ApplicationController

  def new
    @other = SdgPioneer::Other.new
  end

  def create
    @other = SdgPioneer::Other.new(nomination_params)

    if @other.save
      SdgPioneer::Notification.notify_of_nomination(@other)
      redirect_to sdg_pioneer_index_path, notice: I18n.t('sdg_pioneer.nominated')
    else
      render :new
    end
  end

  private

  def nomination_params
    params.require(:other).permit(
      :organization_type,
      :submitter_name,
      :submitter_place_of_work,
      :submitter_job_title,
      :submitter_email,
      :submitter_phone,
      :nominee_name,
      :nominee_work_place,
      :nominee_email,
      :nominee_phone,
      :nominee_title,
      :why_nominate,
      :sdg_pioneer_role,
      :accepts_tou
    )
  end

end
