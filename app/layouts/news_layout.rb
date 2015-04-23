class NewsLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'News'
  layout :news

  has_meta_tags!

  has_hero!

  has_widget_contact!

  has_widget_calls_to_action!

  has_related_content!

  has_resources!

end
