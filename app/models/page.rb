# == Schema Information
#
# Table name: pages
#
#  id                    :integer(4)      not null, primary key
#  path                  :string(255)
#  title                 :string(255)
#  slug                  :string(255)
#  content               :text
#  parent_id             :integer(4)
#  position              :integer(4)
#  display_in_navigation :boolean(1)
#  approved_at           :datetime
#  approved_by_id        :integer(4)
#  created_by_id         :integer(4)
#  updated_by_id         :integer(4)
#  dynamic_content       :boolean(1)
#  version_number        :integer(4)
#  created_at            :datetime
#  updated_at            :datetime
#  group_id              :integer(4)
#  approval              :string(255)
#

class Page < ActiveRecord::Base
  include ContentApproval
  include TrackCurrentUser
  
  before_create :increment_version_number

  belongs_to :section, :class_name => 'PageGroup', :foreign_key => :group_id
  has_many :children, :order => "position ASC", :class_name => 'Page', :foreign_key => :parent_id

  named_scope :all_versions_of, lambda { |path|
    # has_many :versions, :class_name => 'ContentVersion', :order => "content_versions.version_number ASC"
    return {} if path.blank?
    {
      :conditions => ["pages.path = ?", path],
      # :order      => "pages.version_number DESC"
    }
  }
  named_scope :for_navigation, :conditions => {"display_in_navigation" => true}

  named_scope :earlier_versions_than, lambda { |version_version_number|
    {
      :conditions => ["pages.version_number < ?", version_version_number],
      :order => "pages.version_number DESC"
    }
  }
  
  named_scope :later_versions_than, lambda { |version_version_number|
    {
      :conditions => ["pages.version_number > ?", version_version_number],
      :order => "pages.version_number ASC"
    }
  }
  
  def self.for_path(path)
    find_by_path path, :include => :children
  end
  
  def self.find_navigation_for(path)
    return nil if path.blank?
    possible = approved.for_navigation.find_by_path(path, :include => :children) #, :include => :children
    possible = find_parent_directory(path) unless possible # it couldn't be found, but maybe it's inside a "directory"
    possible
  end
  
  def self.find_parent_directory(path)
    # split gives us an empty first element - /second/thing/index.html becomes ["", "second", "thing", "index.html"]
    array = path.split('/')
    times_to_try = array.size - 1 # not the first empty element
    times_to_try.times do
      array.pop
      possible = approved.for_navigation.find_by_path(array.join('/') + '/index.html', :include => :children) # 
      return possible if possible
    end
    nil
  end
  
  def self.find_for_section(path)
    find :all, :conditions => "path REGEXP '^#{path}[^/]+\.html", :group => 'path'
  end
  
  def self.approved_for_path(path)
    approved.find_by_path path
  end
  
  def self.pending_version_for(path)
    with_approval('pending').find_by_path path
  end
  
  def before_approve!
    previously = self.class.approved_for_path(path)
    previously.revoke! if previously
  end
  
  def active_version
    versions.approved.first
  end
  
  def find_version_number(number)
    versions.find_by_version_number number
  end

  def increment_version_number
    max = versions.last
    self.version_number = max ? (max.version_number || 0) + 1 : 1
  end

  def is_child_of?(nav)
    !!parent_id && parent_id == nav.id
  end
  
  def next_version
    self.class.all_versions_of(path).later_versions_than(version_number).first
  end
  
  def new_version(options={})
    options ||= {}
    active = active_version || self
    default_options = {
      :path                  => active.path, 
      :title                 => active.title, 
      :slug                  => active.slug, 
      :group_id              => active.group_id, 
      :parent_id             => active.parent_id, 
      :position              => active.position, 
      :dynamic_content       => active.dynamic_content,
      :display_in_navigation => active.display_in_navigation
    } 
    self.class.create default_options.merge(options) # TODO: Make this work: .merge({:version_number => (version_number || 1) + 1})
  end
  
  def parent
    return nil unless parent_id
    self.class.find_by_id parent_id
  end
  
  def parent=(nav)
    self.parent_id = nav.id
  end
  
  def pending_version
    self.class.pending_version_for(path)
  end
  
  def previous_version
    self.class.all_versions_of(path).earlier_versions_than(version_number).first
  end

  def to_path
    array = path.split('/')
    array.shift
    array
  end

  def update_pending_or_new_version(options={})
    if pending_version
      pending_version.update_attributes(options)
      pending_version
    else
      new_version(options)
    end
  end

  def version_version_number(version_number)
    versions.find_by_version_number version_number
  end

  def versions(*args)
    return [self] unless path
    self.class.all_versions_of(path)
  end
  
end
