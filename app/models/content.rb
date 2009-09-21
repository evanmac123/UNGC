# == Schema Information
#
# Table name: contents
#
#  id         :integer(4)      not null, primary key
#  path       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Content < ActiveRecord::Base
  serialize :path
  has_many :versions, :class_name => 'ContentVersion', :order => "content_versions.number ASC"
  has_one :active_version, :class_name => 'ContentVersion', :conditions => ["content_versions.approved = ?", true]
  attr_writer :content, :template
  before_create :initialize_version
  delegate :dynamic?, :to => :active_version
  
  def self.for_path(look_for)
    find_by_path look_for, :include => :active_version
  end
  
  def content
    @content || active_version.content
  end
  
  def initialize_version
    version = versions.build :content => @content, :template => @template, :path => path #, :number => 1
  end

  def next_version
    active_version.next_version
  end
  
  def new_version(options)
    template = @template || active_version.try(:template) || ContentTemplate.default
    default_options = {:path => path, :template => template}
    versions.create default_options.merge(options)
    # versions.create options.merge(:path => path)
  end
  
  def previous_version
    active_version.previous_version
  end

  def to_path
    array = path.split('/')
    array.shift
    array
  end

  def version_number(number)
    versions.find_by_number number
  end
end
