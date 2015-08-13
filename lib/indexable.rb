module Indexable
  # Usage:
  # include Indexable
  # and ensure that Searchable has a method: remove_your_model_name(model)
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
