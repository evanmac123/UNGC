module Academy
  class ViewersController < ApplicationController

    def new
      @viewer = Viewer.new
    end

    def create
      @viewer = Viewer.new(viewer_params)

      if @viewer.save
        redirect_to new_academy_viewer_url,
          notice: I18n.t("organization.requested_to_join")
      else
        render :new
      end
    end

    def accept
      stream = params.fetch(:viewer_id)
      op = PendingContactOperation.find(stream)
      render text: op.process
    end

    private

    def find_organization
      Organization.find(viewer_params.fetch(:organization_id))
    end

    def viewer_params
      params.require(:viewer).permit(
        :organization_id,
        :organization_name,
        :prefix,
        :first_name,
        :middle_name,
        :last_name,
        :job_title,
        :email,
        :phone,
        :address,
        :address_more,
        :city,
        :state,
        :postal_code,
        :country_id,
        :country_name,
        :username,
      )
    end

  end
end
