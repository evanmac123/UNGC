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
    none
    light
    dark
  ]

  has_one_container!

  label 'Homepage'
  layout :home

  scope :meta_tags do
    field :title, type: :string, required: true
    field :description, type: :string
  end

  scope :hero do
    field :image, type: :image_url
    field :theme, type: :string, enum: THEMES, default: 'light'

    scope :title do
      field :title1, type: :string, limit: 50, required: true
      field :title2, type: :string, limit: 50
    end

    field :blurb, type: :string, limit: 200, required: true

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

  scope :tiles, array: true, min: 3, max: 6 do
    field :color,    type: :string, enum: COLORS, default: 'light-blue', required: true
    field :bg_image, type: :image_url
    field :title,    type: :string, limit: 100, required: true
    field :blurb,    type: :string, limit: 150

    scope :link do
      field :label, type: :string, limit: 25
      field :url,   type: :href
    end

    field :double_width,  type: :boolean, default: false
    field :double_height, type: :boolean, default: false
  end
end
