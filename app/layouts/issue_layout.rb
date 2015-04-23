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

  has_widget_contact!

  has_widget_calls_to_action!

  has_widget_links_lists!

  has_resources!

  has_related_content!
end
