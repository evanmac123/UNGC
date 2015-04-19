class ActionDetailLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  has_one_container!

  label 'Issue'
  layout :issue

  has_meta_tags! do
    field :content_type, type: :number, default: 0
  end

  has_taggings!

  has_hero!

  scope :principles, array: true, min: 0, max: 5 do
    field :principle, type: :number, required: true
  end

  scope :action_detail_block do
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

  scope :related_content do
    field :title, type: :string, limit: 50
    scope :content_boxes, array: true, size: 3 do
      field :container_path, type: :string
    end
  end

  scope :initiative do
    field :initiative_id, type: :number, required: true
  end

  scope :partners, array: true, min: 0, max: 6 do
    field :name, type: :string, required: true
    field :logo, type: :href, required: true
    field :url, type: :href, required: true
  end
end

