class AccordionLayout < UNGC::Layout
  extend UNGC::Layout::Macros
  has_one_container!

  label 'Accordion'
  layout :accordion

  has_meta_tags!

  has_hero!

  scope :accordion do
    field :title, type: :string
    field :blurb, type: :string

    scope :items, array: true, max: 10 do
      field :title, type: :string,  required: true
      field :content, type: :string
      scope :children, array: true, max: 10 do
        field :title, type: :string,  required: true
        field :content, type: :string
      end
    end
  end

  has_widget_contact!

  has_widget_calls_to_action!

  has_widget_links_lists!
end

