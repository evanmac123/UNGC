module PagesHelper
  def versioned_edit_path
    if params[:version].blank?
      edit_content_path(:id => @page)
    else
      edit_content_path(:id => @page, :version => @current_version.number)
    end
  end
end
