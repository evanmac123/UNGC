module PagesHelper
  def versioned_edit_path
    if @current_version.approved?
      edit_content_path(:id => @page)
    else
      edit_content_path(:id => @page, :version => @current_version.number)
    end
  end
end
