module Indexable
  # Usage:
  # include Indexable
  # and ensure that Searchable has a method: remove_your_model_name(model)
  def self.included(receiver)
    method = "remove_#{receiver.model_name.param_key}".to_sym

    receiver.class_eval do
      before_save do
        Redesign::Searchable.update_url(self)
      end

      before_destroy do
        Redesign::Searchable.remove(self)
      end
    end
  end
end
