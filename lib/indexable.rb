module Indexable
  def self.included(receiver)
    receiver.class_eval do
      before_save do
        Searchable.update_url(self)
      end

      before_destroy do
        Searchable.remove(self)
      end
    end
  end
end
