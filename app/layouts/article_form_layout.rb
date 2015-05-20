class ArticleFormLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  has_one_container!

  label 'Article Form'
  layout :article_form

  has_meta_tags!

  has_hero! do
    field :show_section_nav,  type: :boolean, default: true
  end

end
