module Admin::DueDiligence::Helper
  def bool_warn(value)
    # TODO: Apply styles
    color = case value
              when true
                'red'
              when false
                'green'
              else
                'blue'
            end

    as_bool(value, color)
  end

  def blank_warn(value)
    # TODO: Apply styles
    color = value.blank? ? 'blue' : ''
    "<span style=\"color: #{color}\">#{not_researched(value)}</span>".html_safe
  end

  def as_bool(value, color)
    # TODO: Apply styles
    v = case value
          when true
            'Yes'
          when false
            'No'
          else
            not_researched(v)
        end
    "<span style=\"color: #{color}\">#{v}</span>".html_safe
  end

  def not_researched(v)
    v.blank? ? 'Not Researched' : v
  end

  def edit_path_for_review(review, policy, contact=current_contact)
    if review.in_review?
      if policy.can_do_due_diligence?(contact)
        edit_admin_due_diligence_risk_assessment_path(review)
      else
        edit_admin_due_diligence_review_path(review)
      end
    elsif review.local_network_review?
      edit_admin_due_diligence_local_network_review_path(review)
    elsif review.integrity_review?
      edit_admin_due_diligence_integrity_review_path(review)
    elsif %w[engagement_review engaged declined rejected].include?(review.state)
      edit_admin_due_diligence_final_decision_path(review)
    else
      raise "invalid review state for path: #{review.state}"
    end
  end

end
