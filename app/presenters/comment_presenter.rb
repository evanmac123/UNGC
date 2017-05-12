class CommentPresenter < SimpleDelegator

  def contact_name
    __getobj__.contact.name
  end

  def organization_name
    __getobj__.commentable.organization.name
  end

  def participant_manager_email
    __getobj__.commentable.organization.participant_manager_email
  end

  def created_at
    super.to_formatted_s(:short)
  end

end

