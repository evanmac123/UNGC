class LandingLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  COLORS = %w[
    light-blue
    light-green
    teal
    green
    orange
    pastel-blue
  ]

  has_one_container!

  label 'Landing'
  layout :landing

  has_meta_tags!
  has_taggings!

  has_hero! do
    scope :link do
      field :label, type: :string, limit: 30, required: true
      field :url,   type: :href,   required: true
    end
    field :show_section_nav,  type: :boolean, default: false
  end

  scope :tiles, array: true, min: 3, max: 6 do
    field :color,    type: :string, enum: COLORS, default: 'light-blue', required: true
    field :bg_image, type: :image_url
    field :title,    type: :string, limit: 100, required: true
    field :blurb,    type: :string, limit: 150

    scope :link do
      field :label, type: :string, limit: 30
      field :url,   type: :href
    end

    field :double_width,  type: :boolean, default: false
    field :double_height, type: :boolean, default: false
  end
end

