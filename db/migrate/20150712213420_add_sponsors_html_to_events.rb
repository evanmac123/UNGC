class AddSponsorsHtmlToEvents < ActiveRecord::Migration
  def change
    add_column :events, :sponsors_description, :text
  end
end
