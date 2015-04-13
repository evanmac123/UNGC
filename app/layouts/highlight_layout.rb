class HighlightLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  THEMES = %w[
    none
    light
    dark
  ]

  ALIGN = %w[
    left
    center
    right
  ]

  COLORS = %w[
    light-blue
    light-green
    teal
    green
    orange
    pastel-blue
  ]

  has_one_container!

  label 'Highlight'
  layout :highlight

  has_meta_tags!
  has_taggings!

  scope :hero do
    field :image, type: :image_url
    field :theme, type: :string, enum: THEMES, default: 'light'

    scope :title do
      field :title1, type: :string, limit: 50, required: true
      field :title2, type: :string, limit: 50
    end

    field :blurb, type: :string, limit: 200, required: true
    field :show_section_nav,  type: :boolean, default: false
  end

  scope :article_blocks, array: true, min: 1, max: 3 do
    field :align,    type: :string, enum: ALIGN, default: 'left'
    field :theme, type: :string, enum: THEMES, default: 'light'
    field :title,    type: :string, limit: 100, required: true
    field :content,  type: :string, required: true
    field :bg_image, type: :image_url
    scope :widget_image do
      field :alt, type: :string, limit: 50
      field :src,   type: :href
    end
    scope :call_to_action do
      field :theme, type: :string, enum: COLORS, default: 'light-blue'
      field :title, type: :string, limit: 50
      field :url,   type: :href
      field :enabled,  type: :boolean, default: false
    end
  end

end
