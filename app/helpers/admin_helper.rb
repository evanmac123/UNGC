module AdminHelper
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

  def link_to_uploaded_file(object)
    if object
      options = {:title => object.attachment_unmodified_filename}
      name = truncate options[:title], :length => 100
      link_to(name, admin_uploaded_file_path(object, object.attachment_unmodified_filename), options)
    else
      'No file'
    end
  end

  # Outputs a table header that is also a link to sort the current data set
  def sort_header(label, options={})
    if @order.nil? || @order.split(' ').first != options[:field]
      # this is the default direction
      direction = options[:direction] || 'DESC'
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
    days_ago = (Date.current - date.to_date).to_i
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

  def display_readable_errors(object)
     error_messages = object.readable_error_messages.map { |error| content_tag :li, error }
     content_tag :ul, error_messages.join.html_safe
  end

  def popup_link_to(text, url, options={})
    link_to text.html_safe, url, :title => options[:title], :class => options[:class], :data => {'popup' => true}
  end

  def participant_manager_only(&block)
    yield if current_contact.is? Role.participant_manager
  end

  def staff_only(&block)
    yield if current_contact && current_contact.from_ungc?
  end

  def staff_participant_manager_only(&block)
    if current_contact && current_contact.from_ungc? &&
        current_contact.is?(Role.participant_manager)
      yield
    end
  end

  def organization_only(&block)
    yield if current_contact && current_contact.from_organization?
  end

  def css_display_style(show)
    "display: #{show ? 'block' : 'none'}"
  end

  def retina_image(model, size, options={})
    options[:data] ||= {}
    options[:data].merge!(:at2x => model.cover_image(size, retina: true))
    image_tag model.cover_image(size), options
  end

  def cop_action_links(cop)
    actions = []
    if current_contact.from_ungc?
      actions << link_to('Approve', admin_communication_on_progress_comments_path(cop, :commit => LogoRequest::EVENT_APPROVE.titleize), :method => :post) if cop.can_approve?
      actions << link_to('Reject', admin_communication_on_progress_comments_path(cop.id, :commit => LogoRequest::EVENT_REJECT.titleize), :method => :post) if cop.can_reject?
    end
    links = actions.join(" | ")
    content_tag :p, links unless links.blank?
  end

  def dashboard_link_to_public_profile(local_network)
    if local_network.country_code.present?
      link = "/NetworksAroundTheWorld/local_network_sheet/#{local_network.country_code}.html"
    else
      link = "/NetworksAroundTheWorld/"
    end
  end

  def announcement_count
    @announcements.count > 0 ? "(#{@announcements.count})" : ''
  end

  def current_contact_can_edit_network?
    current_contact.from_ungc? || (current_contact.local_network == @local_network)
  end

  def name_for_edit_link(current_contact)
    if current_contact.from_organization?
      "Edit your organization's profile"
    else
      "Edit"
    end
  end

  def full_organization_status(organization)
    if organization.approved? && organization.participant?
      # they've been approved, but only participants have a COP state
      if organization.delisted?
        status = "#{organization.delisted_on} (Delisted)"
      else
        status = organization.cop_state.humanize
      end
    elsif organization.in_review? || organization.delay_review?
      review_reason = " - #{organization.review_reason_value}" if organization.review_reason_value.present?
      status = current_contact.from_organization? ? 'Application is under review' : "#{organization.state.humanize}#{review_reason}"
    elsif organization.network_review?
      status = current_contact.from_organization? ? 'Application is under review' : "Network Review: #{network_review_period(organization).downcase}"
    else
      status = organization.state.humanize
    end
  end

  def display_id_type(organization)
    if organization.approved?
      if organization.participant?
        'Participant ID'
      else
        'Organization ID'
      end
    else
      'Application ID'
    end
  end

  def local_network_membership
    # TODO: should be replaced with @organization.local_networks.any? when implemented
    case @organization.is_local_network_member
      when true
        'Member'
      when false
        'Not a member'
      else
        'Unknown'
    end
  end

  def local_network_and_contact_exists?
    @organization.local_network_name.present? && @organization.network_contact_person.present?
  end

  def link_to_getting_started
    WelcomePackage.new(@organization).link
  end

  def link_to_local_network_welcome_letter_if_exists
    filename = "/docs/networks_around_world_doc/communication/welcome_letters/local_network_welcome_letter_#{@organization.local_network_country_code}.pdf"
    if FileTest.exists?("public/#{filename}")
      link_to "Welcome Letter from your Local Network", filename, :class => 'pdf'
    end
  end

  def current_contact_can_delete(current_contact, tabbed_contact)
    ContactPolicy.new(current_contact).can_destroy?(tabbed_contact)
  end

  def edit_admin_cop_path(cop)
    if cop.is_grace_letter?
      edit_admin_organization_grace_letter_path(cop.organization.id, cop.id)
    elsif cop.is_reporting_cycle_adjustment?
      edit_admin_organization_reporting_cycle_adjustment_path(cop.organization.id, cop.id)
    else
      edit_admin_organization_communication_on_progress_path(cop.organization.id, cop.id)
    end
  end

  def admin_cop_path(cop)
    if cop.is_grace_letter?
      admin_organization_grace_letter_path(cop.organization.id, cop)
    elsif cop.is_reporting_cycle_adjustment?
      admin_organization_reporting_cycle_adjustment_path(cop.organization.id, cop)
    else
      admin_organization_communication_on_progress_path(cop.organization.id, cop)
    end
  end

  def language_options(language_id)
    options_from_collection_for_select(Language.all, :id, :name, language_id)
  end
end
