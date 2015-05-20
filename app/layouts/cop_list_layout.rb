class CopListLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'Cop List'
  layout :cop_list

  has_meta_tags!

  has_hero!
end
