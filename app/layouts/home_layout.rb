class HomeLayout < UNGC::Layout
  has_one_container!

  label 'Homepage'

  field :title, limit: 100
  field :main_heading, limit: 100
  field :main_text, limit: 500
  field :main_button_caption, limit: 20
  field :main_button_path

  has 5, :main_links do
    field :label, limit: 20
    field :path,  limit: 20
    field :icon,  limit: 100
  end

  has 3, :stats do
    field :number, limit: 16
    field :label, limit: 30
  end
end
