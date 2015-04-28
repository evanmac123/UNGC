class EngageLocallyLayout < UNGC::Layout
  extend UNGC::Layout::Macros

  has_one_container!

  label 'Engage Locally'
  layout :engage_locally

  has_meta_tags!

  has_taggings!

  has_hero!

  scope :content_block do
    field :title,    type: :string, limit: 100, required: true
    field :content,  type: :string, required: true
  end

  has_widget_contact!

  has_widget_calls_to_action!

  has_resources!

  has_related_contents!

end
