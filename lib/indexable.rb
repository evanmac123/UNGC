module Indexable
  def self.included(receiver)
    receiver.class_eval do
      before_save do
        Searchable.update_url(self)
      end

      after_commit on: :update do
        Searchable.update_or_evict(self)
      end

      before_destroy do
        Searchable.remove(self)
      end
    end
  end
end
