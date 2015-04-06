class LandingLayout < UNGC::Layout
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

  label 'Landing'
  layout :landing

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

