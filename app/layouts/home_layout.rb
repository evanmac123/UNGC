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
    field :theme, type: :enum, values: THEMES, default: 'light'
    field :title, type: :string, required: true
    field :blurb, type: :string, array: true, min: 2, max: 2

    scope :link do
      field :label, type: :string
      field :url,   type: :href, required: ->(s) { s[:label].present? }
    end

    field :show_issues_nav, type: :boolean, default: true
  end

  scope :stats, array: true, min: 3, max: 3 do
    field :value, type: :string
    field :label, type: :string
  end

  scope :tiles, array: true, min: 3, max: 8 do
    field :color,    type: :enum, values: COLORS, default: 'light-blue'
    field :bg_image, type: :image_url
    field :title,    type: :string

    scope :link do
      field :label, type: :string
      field :url,   type: :href, required: ->(s) { s[:label].present? }
    end

    field :double_width,  type: :boolean
    field :double_height, type: :boolean
  end
end
