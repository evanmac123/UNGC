module Academy
  class ViewersController < ApplicationController

    def new
      @viewer = Viewer.new
    end

    def create
      @viewer = Viewer.new(viewer_params)

      success, message = @viewer.submit_pending_operation
      if success
        redirect_to new_academy_viewer_url, notice: message
      else
        render :new
      end
    end

    def accept
      stream = params.fetch(:viewer_id)
      op = PendingContactOperation.find(stream)
      op.process
      @contact = op.contact
      @organization = @contact.organization
      @message = op.status
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
