class IssueLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  THEMES = %w[
    none
    light
    dark
  ]

  has_one_container!

  label 'Issue'
  layout :issue

  has_meta_tags!
  has_taggings!

  scope :hero do
    field :image, type: :image_url
    field :theme, type: :string, enum: THEMES, default: 'light'

    scope :title do
      field :title1, type: :string, limit: 50, required: true
      field :title2, type: :string, limit: 50
    end

    field :blurb, type: :string, limit: 200, required: true
  end

  scope :issue_block do
    field :title,    type: :string, limit: 100, required: true

    scope :principles, array: true, max: 5 do
      field :label, type: :string, limit: 20, required: true
      field :blurb, type: :string, required: true, required: true
      field :url,   type: :href,   required: true, required: true
    end

    field :content,  type: :string, required: true
  end

  scope :widget_contact do
    field :contact_id, type: :number
  end

  scope :widget_calls_to_action, array: true, min: 1, max: 2 do
    field :label, type: :string, limit: 50, required: true
    field :url,   type: :href,   required: true
  end

  scope :widget_links_list do
    field :title, type: :string, limit: 50

    scope :links, array: true, max: 5 do
      field :label, type: :string, limit: 20, required: true
      field :url,   type: :href,   required: true
    end
  end

  scope :resources, array: true, size: 3 do
    field :resource_id, type: :number, required: true
  end

  scope :related_content, array: true, size: 3 do
    field :container_path, type: :string
  end
end
