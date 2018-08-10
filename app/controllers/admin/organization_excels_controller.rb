class Admin::OrganizationExcelsController < AdminController

  def new
    @excel_organization = OrganizationExcel.new
  end

  def import
    OrganizationExcel.import(params[:file])
    redirect_to new_admin_organization_excel_path, notice: "Organization level of participation are now imported."
  end
end
