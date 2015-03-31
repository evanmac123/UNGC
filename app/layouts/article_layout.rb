class ArticleLayout < UNGC::Layout
  has_one_container!

  label 'Article'
  layout :article

  scope :hero do
    scope :title do
      field :title1, type: :string, limit: 50, required: true
      field :title2, type: :string, limit: 50
    end
  end

  scope :article_block do
    field :title,    type: :string, limit: 100, required: true
    field :content,  type: :string
  end

  scope :contact_widget do
    field :contact_id, type: :string # XXX should be number
  end

  scope :call_to_action do
    field :label, type: :string, limit: 50, required: true
    field :url,   type: :href,   required: true
  end

  scope :links_block do
    filed :title, type: :string, limit: 50, required: true

    scope :links, array: true, size: 3 do
      field :label, type: :string, limit: 20, required: true
      field :url,   type: :href,   required: true
    end
  end
end

