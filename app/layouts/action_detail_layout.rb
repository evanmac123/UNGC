class ActionDetailLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  has_one_container!

  label 'Action Detail'
  layout :action_detail

  has_meta_tags! do
    field :content_type, type: :number, default: 0
  end

  has_taggings!

  has_hero!

  has_principles!

  scope :action_detail_block do
    field :title,    type: :string, limit: 100, required: true

    field :content,  type: :string, required: true
  end

  has_widget_contact!

  has_widget_calls_to_action!

  has_widget_links_lists!

  has_resources!

  has_related_contents!

  scope :initiative do
    field :initiative_id, type: :number
  end

  scope :partners, array: true, min: 0, max: 6 do
    field :name, type: :string, required: true
    field :logo, type: :href, required: true
    field :url, type: :href, required: true
  end
end
