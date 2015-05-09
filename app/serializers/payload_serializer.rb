class PayloadSerializer < ApplicationSerializer
  def attributes
    h = super
    h[:data]         = object.data
    h[:container_id] = object.container_id
    h[:created_at]   = object.created_at
    h[:updated_at]   = object.updated_at
    h[:updated_by_id]  = object.updated_by_id
    h[:approved_by_id] = object.approved_by_id
    h
  end
end
