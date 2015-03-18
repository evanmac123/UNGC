class HomeLayout < UNGC::Layout
  COLORS = %w[
    light-blue
    light-green
    teal
    green
    orange
    pastel-blue
  ]

  THEMES = %w[
    light
    dark
  ]

  has_one_container!

  label 'Homepage'
  layout :home

  scope :hero do
    field :image, type: :image_url
    field :theme, type: :string, enum: THEMES, default: 'light'
    field :title, type: :string, required: true, limit: 100
    field :blurb, type: :string, array: true, limit: 100, min: 2, max: 2

    scope :link do
      field :label, type: :string, limit: 30, required: true
      field :url,   type: :href,   required: true
    end

    field :show_issues_nav, type: :boolean, default: true
  end

  scope :stats, array: true, size: 3 do
    field :value, type: :string, limit: 20, required: true
    field :label, type: :string, limit: 20, required: true
  end

  scope :tiles, array: true, size: 6 do
    field :color,    type: :string, enum: COLORS, default: 'light-blue', required: true
    field :bg_image, type: :image_url
    field :title,    type: :string, limit: 100, required: true

    scope :link do
      field :label, type: :string, limit: 25
      field :url,   type: :href
    end

    field :double_width,  type: :boolean, default: false
    field :double_height, type: :boolean, default: false
  end
end
