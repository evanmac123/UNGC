class ListLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  LIST_LINK_TYPES = %w[
    none
    pdf
    video
    web
  ]

  SORTING = %w[
    asc
    desc
  ]

  has_one_container!

  label 'List'
  layout :list

  has_meta_tags!

  has_taggings!

  has_hero! do
    field :show_section_nav,  type: :boolean, default: true
  end

  scope :list_block do
    field :title, type: :string, required: true
    field :blurb, type: :string
    field :sorting, type: :string, enum: SORTING, default: 'asc'
    scope :items, array: true, min: 1 do
      field :url, type: :href
      field :external, type: :boolean, default: false
      field :title, type: :string, required: true
      field :type, type: :string, enum: LIST_LINK_TYPES, default: 'none'
      field :blurb, type: :string
      field :image, type: :image_url
    end
  end

end
