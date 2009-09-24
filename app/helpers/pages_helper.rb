module PagesHelper

  def versioned_edit_path
    if @current_version.approved?
      edit_content_path(:id => @page)
    else
      edit_content_path(:id => @page, :version => @current_version.number)
    end
  end

  # TODO: Are we using this anywhere?
  # def paged_participants(filter_type=nil)
  #   unless @paged_participants 
  #     @paged_participants = if filter_type # FIXME: Real pagination! @jaw6
  #       Organization.by_type(filter_type).find(:all, :limit => 20)
  #     else
  #       Organization.find(:all, :limit => 20)
  #     end
  #   end
  #   @paged_participants
  # end

end
