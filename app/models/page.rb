# == Schema Information
#
# Table name: pages
#
#  id                    :integer(4)      not null, primary key
#  path                  :string(255)
#  title                 :string(255)
#  html_code             :string(255)
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
#  top_level             :boolean(1)
#

class Page < ActiveRecord::Base
  class PathCollision < Exception; end
  
  include ContentApproval
  include TrackCurrentUser
  
  before_create :increment_version_number
  before_create :derive_path

  belongs_to :section, :class_name => 'PageGroup', :foreign_key => :group_id
  has_many :children, :order => "position ASC", :class_name => 'Page', :foreign_key => :parent_id
  has_many :visible_children, 
    :order       => "position ASC", 
    :class_name  => 'Page', 
    :foreign_key => :parent_id, 
    :conditions  => {:display_in_navigation => true, approval: 'approved'}
  has_many :approved_children, 
    :order       => 'position ASC', 
    :class_name  => 'Page', 
    :foreign_key => :parent_id, 
    :conditions  => { approval: 'approved' }

  named_scope :all_versions_of, lambda { |path|
    return {} if path.blank?
    {
      :conditions => ["pages.path = ?", path],
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

  def self.find_leaves_for(group_id)
    sql = "select * from 
      (select * 
        from pages 
        where group_id = %i 
          and ((approval = %s) or (approval = %s))
        order by path asc, approval desc, updated_at desc) as t1
      group by t1.path
      order by t1.position asc" % [group_id, "'approved'", "'pending'"]
    results = find_by_sql(sql)
    results.group_by { |r| r.parent_id } if results.any?
  end
  
  def self.pending_version_for(path)
    with_approval('pending').find_by_path path
  end
  
  def before_approve!
    all_versions = self.class.all_versions_of(path)
    if change_path
      self.class.update_all "pages.path = '%s'" % change_path, { id: (all_versions - [self]).map(&:id) }
      self.path = change_path
      self.change_path = nil
    end
    if previous = all_versions.with_approval('approved').try(:first)
      previous.move_children_to_new_parent(id)
      previous.revoke! if previous.approved?
    end
    # if previous = all_versions.with_approval('approved')
    #   self.class.update_all "pages.approval = '%s'" % STATES[:previously], { id: (previous).map(&:id) }
    # end
  end
  
  def active_version
    versions.approved.first
  end
  
  def move_children_to_new_parent(new_parent_id)
    children.each { |child| child.update_attribute :parent_id, new_parent_id }
  end
  
  # Children are attached to an approved parent, the tree needs to reflect their connection
  # to a new, pending version of that page
  def approved_id
    if approved?
      id
    elsif av = active_version
      av.id
    else
      nil
    end
  end
  
  def derive_path
    return true unless path.blank?
    if parent || parent_id
      derive_path_from_parent
    elsif section || group_id
      derive_path_from_section
    end
  end
  
  def derive_path_from_parent
    parent = parent || Page.find(parent_id)
    (stub = parent.path)[/(\/index)?\.html$/] = ''
    new_path = "#{stub}/#{title_to_path}.html"
    self.path = new_path.gsub(/\/+/, '/')
  end
  
  def derive_path_from_section
    section = section || PageGroup.find_by_id(group_id)
    stub = "/#{section.path_stub}" if section
    new_path = "#{stub}/#{title_to_path}.html"
    self.path = new_path.gsub(/\/+/, '/')
  end
  
  def derive_path_from=(string)
    type_str, identifier = TreeImporter.get_type_and_id(string)
    if identifier
      if type_str == 'page'
        self.parent_id = identifier
        self.group_id  = Page.find(identifier).group_id
      else
        self.group_id = identifier
      end
    elsif type_str == 'section' # in home area
      self.path ||= "/#{title_to_path}.html"
    end
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
      :html_code                  => active.html_code, 
      :group_id              => active.group_id, 
      :parent_id             => active.parent_id, 
      :position              => active.position, 
      :dynamic_content       => active.dynamic_content,
      :display_in_navigation => active.display_in_navigation
    } 
    default_options.stringify_keys!
    options.stringify_keys!
    self.class.create default_options.merge(options) # TODO: Make this work: .merge({:version_number => (version_number || 1) + 1})
  end
  
  def parent
    return nil unless parent_id
    self.class.find_by_id parent_id
  end
  
  def parent=(nav)
    self.parent_id = nav.id
  end
  
  def pending_version(new_path=nil)
    self.class.pending_version_for(new_path || path)
  end
  
  def previous_version
    self.class.all_versions_of(path).earlier_versions_than(version_number).first
  end

  def rename(string)
    old_path   = title_to_path
    self.title = string
    new_path   = path.gsub(old_path, title_to_path)
    self.path  = path.gsub(old_path, title_to_path) if 0 == self.class.all_versions_of(new_path).size
    save
  end

  def title_to_path
    path = title.downcase
    path.gsub!(/\W+/, '_')
    path.gsub!(/_+/, '_')
    path.gsub!(/_$/, '')
    path
  end

  def to_path
    path.split('/').reject { |s| s == '' }
  end

  def pages_exist_with_new_path?(path)
    self.class.all_versions_of(path).any?
  end

  def possibly_move_paths(new_path)
    if path == new_path # don't do anything unless there's an actual change
      return nil
    else
      if pages_exist_with_new_path?(new_path)
        raise PathCollision
      else
        return new_path
      end
    end
  end

  def update_pending_or_new_version(their_options={})
    options = their_options.dup
    options.stringify_keys!
    if new_path = options.delete('path') and result = possibly_move_paths(new_path)
      options['change_path'] = result
    end
    return self.reload unless options.any?
    unless their_options['dynamic_content'].blank?
      bool = their_options['dynamic_content'] == '1'
      their_options['dynamic_content'] = bool
    end
    if v = pending_version(path)
      v.update_attributes(options)
      v
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
  
  def wants_to_change_path_and_can?(options={})
    options.stringify_keys!
    new_path = options['path']
    wants_to = !new_path.blank? && new_path != path
    return true unless wants_to
    can      = !pages_exist_with_new_path?(new_path)
    wants_to and can
  end
  
end
