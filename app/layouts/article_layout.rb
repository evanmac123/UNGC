class ArticleLayout < UNGC::Layout

  THEMES = %w[
    none
    light
    dark
  ]

  has_one_container!

  label 'Article'
  layout :article

  scope :hero do
    scope :title do
      field :title1, type: :string, limit: 50, required: true
      field :title2, type: :string, limit: 50
    end
  end
  scope :hero do
    field :image, type: :image_url
    field :theme, type: :string, enum: THEMES, default: 'light'

    scope :title do
      field :title1, type: :string, limit: 50, required: true
      field :title2, type: :string, limit: 50
    end

    field :blurb, type: :string, limit: 200, required: true
  end

  scope :article_block do
    field :title,    type: :string, limit: 100, required: true
    field :content,  type: :string, required: true
  end

  scope :widget_contact do
    field :contact_id, type: :number
  end

  scope :widget_call_to_action do
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
end

