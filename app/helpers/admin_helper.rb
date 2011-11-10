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
    options = {}
    # clean this up
    return 'Not available' if object.send("#{file}_file_name").blank?
    if object.send("#{file}_file_name").downcase.ends_with?('.pdf')
      options = {:class => 'pdf'}
    elsif object.send("#{file}_file_name").downcase.ends_with?('.jpg')
      options = {:class => 'jpg'}
    elsif object.send("#{file}_file_name").downcase.ends_with?('.ppt') || object.send("#{file}_file_name").downcase.ends_with?('.pptx')
      options = {:class => 'ppt'}
    elsif object.send("#{file}_file_name").downcase.ends_with?('.doc') || object.send("#{file}_file_name").downcase.ends_with?('.docx')
      options = {:class => 'word'}
    end
    
    if object.is_a?(UploadedFile)
      options[:title] = object.send("#{file}_unmodified_filename")
      name = truncate options[:title], :length => 65
      link_to(name, admin_uploaded_file_path(object, object.attachment_unmodified_filename), options)
    else
      options[:title] = object.send("#{file}_file_name")
      name = truncate options[:title], :length => 65
      link_to name, object.send(file).url, options
    end

  end
  
  def link_to_uploaded_file(uploaded_file)
    if uploaded_file
      link_to(uploaded_file.attachment_unmodified_filename, admin_uploaded_file_path(uploaded_file, uploaded_file.attachment_unmodified_filename))
    else
      'No file'
    end
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
                           sort_direction: direction,
                           tab:            options[:tab]), :class => html_class
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
  
  def display_readable_errors(object)
     error_messages = object.readable_error_messages.map { |error| content_tag :li, error }
     content_tag :ul, error_messages.join
  end
  
  def popup_link_to(text, url, options={})
    link_to text, url, {:popup => ['left=50,top=50,height=600,width=1024,resizable=1,scrollbars=1'], :title => options[:title], :class => options[:class]}
  end
  

end
