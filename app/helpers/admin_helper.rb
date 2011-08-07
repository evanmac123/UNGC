module AdminHelper
  def path_for_polymorphic_commentables(commentable)
    case commentable
    when CaseStory
      admin_case_story_comments_path(commentable)
    when Organization
      admin_organization_comments_path(commentable.id)
    when CommunicationOnProgress
      admin_communication_on_progress_comments_path(commentable)
    else
      raise "Polymorphic comment wasn't aware of #{commentable.inspect}".inspect
    end
  end
  
  def path_for_polymorphic_commentable(commentable, comment)
    case commentable
    when CaseStory
      new_admin_case_story_comment_path(commentable)
    when Organization
      new_admin_organization_comment_path(commentable.id)
    when CommunicationOnProgress
      new_admin_communication_on_progress_comment_path(commentable)
    else
      raise "Polymorphic comment wasn't aware of #{commentable.inspect}".inspect
    end
  end
  
  def possibly_link_to_organization
    link_to 'Organization details', admin_organization_path(current_user.organization.id) if logged_in?
  end
  
  def possibly_link_to_edit_organization
    link_to 'Edit your organization', edit_admin_organization_path(current_user.organization.id) if logged_in?
  end
  
  def link_to_attached_file(object, file='attachment')
    return 'Not available' if object.send("#{file}_file_name").blank?
    if object.send("#{file}_file_name").downcase.ends_with?('.pdf')
      name = "PDF document"
      options = {:title => 'Download PDF document', :class => 'pdf_doc'}
    elsif object.send("#{file}_file_name").downcase.ends_with?('.doc') ||
            object.send("#{file}_file_name").downcase.ends_with?('.docx')
      name = "Word document"
      options = {:title => 'Download Word document', :class => 'word_doc'}
    else
      name = "Document"
      options = {:title => 'Download document'}
    end

    link_to name, object.send(file).url, options
  end
  
  # Outputs a table header that is also a link to sort the current data set
  def sort_header(label, options={})
    if @order.nil? || @order.split(' ').first != options[:field]
      # this is the default direction
      direction = options[:direction] || 'ASC'
    else
      # current field, so let's invert the direction
      direction = (@order.split(' ').last == 'ASC') ? 'DESC' : 'ASC'
    end
    
    # defines the HTML class for the link, based on the direction of the link
    if @order.split(' ').first == options[:field]
      html_class = {'ASC' => 'descending', 'DESC' => 'ascending'}[direction]
    end
    link_to label, url_for(sort_field:     options[:field],
                           sort_direction: direction), :class => html_class
  end
  
  # describes the number of days since last event
  def display_days_ago(date)
    days_ago = (Date.today.to_date - date.to_date).to_i
    case days_ago
      when 0
        'Today'
      when 1
        'Yesterday'
      else
        days_ago.to_s + ' days ago'
    end
  end

  def edit_contact_path(contact)
    contact_path(contact, :action => :edit)
  end
  
  def show_check(condition)
    condition ? 'checked' : 'unchecked'
  end

end
