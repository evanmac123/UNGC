class PayloadSerializer < ApplicationSerializer
  def attributes
    h = super
    h[:data]         = object.data
    h[:container_id] = object.container_id
    h[:created_at]   = object.created_at
    h[:updated_at]   = object.updated_at
    h
  end
end
