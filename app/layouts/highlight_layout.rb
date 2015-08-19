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

  BUTTON_COLORS = %w[
    dark-teal
    dark-orange
    orange
    dark-blue
    blue
    light-blue
    dark-green
    green
    light-green
  ]

  has_one_container!

  label 'Highlight'
  layout :highlight

  has_meta_tags!
  has_taggings!

  has_hero! do
    scope :link do
      field :label, type: :string, limit: 30
      field :url,   type: :href
    end
    field :show_section_nav,  type: :boolean, default: false
  end

  scope :article_blocks, array: true, min: 1, max: 3 do
    field :align,    type: :string, enum: ALIGN, default: 'left'
    field :theme, type: :string, enum: THEMES, default: 'light'
    field :title,    type: :string, limit: 70, required: true
    field :content,  type: :string, required: true
    field :bg_image, type: :image_url
    scope :widget_image do
      field :alt, type: :string
      field :src,   type: :href
      field :url,   type: :href
      field :external, type: :boolean, default: false
    end
    scope :call_to_action do
      field :theme, type: :string, enum: BUTTON_COLORS, default: 'light-blue'
      field :title, type: :string, limit: 50
      field :url,   type: :href
      field :enabled,  type: :boolean, default: false
      field :external, type: :boolean, default: false
    end
  end

  has_resources!

end
