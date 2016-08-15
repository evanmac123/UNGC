module Admin::ResourcesHelper
  def resource_sort_field(status)
    status == :approved ? 'approved_at' : 'updated_at'
  end
end
