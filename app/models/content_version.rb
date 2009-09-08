# == Schema Information
#
# Table name: content_versions
#
#  id            :integer(4)      not null, primary key
#  number        :integer(4)
#  approved      :boolean(1)
#  approved_at   :datetime
#  approved_by   :integer(4)
#  path          :string(255)
#  content       :text
#  created_by_id :integer(4)
#  content_id    :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#

class ContentVersion < ActiveRecord::Base
  belongs_to :parent, :class_name => 'Content'
  
  def approve!
    ContentVersion.clear_approval(self)
    update_attribute :approved, true
  end

  def self.clear_approval(version_to_be_approved)
    others = find_all_by_content_id(version_to_be_approved.content_id) - [version_to_be_approved]
    if others.any?
      others.each { |v| 
        v.update_attribute(:approved, false)
      }
    end
  end

end
