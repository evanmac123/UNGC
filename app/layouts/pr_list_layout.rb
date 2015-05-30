class PrListLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'Press Release List'
  layout :pr_list

  has_meta_tags!

  has_hero! do
    field :show_section_nav,  type: :boolean, default: true
  end
end
