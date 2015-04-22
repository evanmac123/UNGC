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

  scope :widget_contact do
    field :contact_id, type: :number
  end

  scope :widget_calls_to_action, array: true, min: 1, max: 2 do
    field :label, type: :string, limit: 50, required: true
    field :url,   type: :href,   required: true
  end

  has_widget_links_lists!

  scope :resources, array: true, max: 3 do
    field :resource_id, type: :number
  end
end

