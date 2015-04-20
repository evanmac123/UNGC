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


  has_hero!

  scope :principles, array: true, min: 0, max: 5 do
    field :principle, type: :number, required: true
  end

  scope :issue_block do
    field :title,    type: :string, limit: 100, required: true
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

  scope :resources, array: true, max: 3 do
    field :resource_id, type: :number
  end

  scope :related_content do
    field :title, type: :string, limit: 50
    scope :content_boxes, array: true, size: 3 do
      field :container_path, type: :string
    end
  end
end
