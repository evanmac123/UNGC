class Content < ActiveRecord::Base
  serialize :path
  
  def self.for_path(look_for)
    find_by_path look_for
  end
end
