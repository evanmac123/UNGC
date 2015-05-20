class EventLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'Events'
  layout :events

  has_meta_tags!

  has_hero!

end
