class EventLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'Events'
  layout :events

  has_meta_tags!

  has_hero! do
    scope :link do
      field :label, type: :string, limit: 30
      field :url,   type: :href
    end
  end

end
