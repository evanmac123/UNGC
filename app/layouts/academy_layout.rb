# frozen_string_literal: true

class AcademyLayout < UNGC::Layout
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

  label "Academy"
  layout :academy

  has_one_container!
  has_meta_tags!

  has_hero! do
    scope :link do
      field :label, type: :string, limit: 30
    end
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

  scope :accordion do
    field :title, type: :string, limit: 100
    field :blurb, type: :string

    scope :items, array: true do
      field :title, type: :string,  required: true
      field :content, type: :string
      scope :children, array: true do
        field :title, type: :string,  required: true
        field :content, type: :string
      end
    end
  end

  scope :logos_and_partners do
    field :align,    type: :string, enum: ALIGN, default: 'left'
    field :theme, type: :string, enum: THEMES, default: 'light'
    field :title,    type: :string, limit: 70, required: true
    field :content,  type: :string, required: true
    field :bg_image, type: :image_url
  end

end
