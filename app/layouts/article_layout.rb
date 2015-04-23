class ArticleLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  THEMES = %w[
    none
    light
    dark
  ]

  has_one_container!

  label 'Article'
  layout :article

  has_meta_tags! do
    field :content_type, type: :number, default: 0
  end

  has_taggings!

  has_hero!

  scope :article_block do
    field :title,    type: :string, limit: 100, required: true
    field :content,  type: :string, required: true
  end

  has_widget_contact!

  has_widget_calls_to_action!

  has_widget_links_lists!

  has_resources!
end

