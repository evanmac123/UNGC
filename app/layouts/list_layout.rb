class ListLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  LIST_LINK_TYPES = %w[
    none
    pdf
  ]

  has_one_container!

  label 'List'
  layout :list

  has_meta_tags!

  has_hero!

  scope :list_block do
    field :title, type: :string, required: true
    field :blurb, type: :string
    scope :items, array: true, min: 1, max: 10 do
      field :url, type: :href
      field :title, type: :string, required: true
      field :type, type: :string, enum: LIST_LINK_TYPES, default: 'none'
      field :blurb, type: :string
      field :image, type: :image_url
    end
  end

end
