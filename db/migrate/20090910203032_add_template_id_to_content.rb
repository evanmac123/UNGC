class AddTemplateIdToContent < ActiveRecord::Migration
  def self.up
    add_column :content_versions, :template_id, :integer
    Content.reset_column_information
    default_template = ContentTemplate.default
    if default_template
      ContentVersion.find_each do |cv|
        unless cv.template_id
          cv.template_id ||= default_template.id
          cv.save!
        end
      end
    end
  end

  def self.down
    remove_column :content_versions, :template_id
  end
end
