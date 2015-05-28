module Indexable
  # Usage:
  # include Indexable
  # and ensure that Searchable has a method: remove_your_model_name(model)
  def self.included(receiver)
    method = "remove_#{receiver.model_name.param_key}".to_sym

    unless Searchable.respond_to?(method)
      raise "Searchable must respond to #{method}"
    end

    receiver.class_eval do
      before_destroy do
        Redesign::Searchable.remove(self)
        Searchable.public_send(method, self)
      end
    end
  end
end
