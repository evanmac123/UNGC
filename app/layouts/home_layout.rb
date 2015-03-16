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

  scope :stats, array: true, min: 3, max: 3 do
    field :value, type: :string, limit: 20
    field :label, type: :string, limit: 20
  end

  scope :tiles, array: true, min: 3, max: 8 do
    field :color,    type: :enum, values: COLORS, default: 'light-blue'
    field :bg_image, type: :image_url
    field :title,    type: :string, limit: 100

    scope :link do
      field :label, type: :string, limit: 25
      field :url,   type: :href, required: ->(s) { s[:label].present? }
    end

    field :double_width,  type: :boolean
    field :double_height, type: :boolean
  end
end
