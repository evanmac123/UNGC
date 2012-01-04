module Admin::CaseStoriesHelper
  def action_links(case_story)
    actions = []
    if current_user.from_ungc?
      actions << link_to('Approve', admin_case_story_comments_path(case_story, :commit => LogoRequest::EVENT_APPROVE.titleize), :method => :post) if case_story.can_approve?
      actions << link_to('Reject', admin_case_story_comments_path(case_story.id, :commit => LogoRequest::EVENT_REJECT.titleize), :method => :post) if case_story.can_reject?
    end
    links = actions.join(" | ")
    content_tag :p, links unless links.blank?
  end

  def case_story_type(case_story)
    type = []
    type << "Internalization" if case_story.is_internalization_project?
    type << "Partnership" if case_story.is_partnership_project?
    return "" if type.empty?
    "#{type.join('&')} Project"
  end
end
