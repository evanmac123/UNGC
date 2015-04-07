class ContainerUpdate

  def initialize(container, data)
    @container = container
    @taggings = data.delete(:taggings)
    @container_data = data
  end

  def submit
    #taggings: {
    #  topics: [213, 123 ,123]
    #  issues: [
    #}

    Redesign::Container.transaction do
      @container.update(@container_data)
      @taggings.each do |type, ids|
        ids.each do |id|
          params = {container_id: @container.id}
          params[type] = id
          Tagging.where(params).first_or_create!
        end

        Tagging
          .where(container_id: @container.id)
          .where('? not in (?)', type, ids)
          .destroy_all
      end

    end
  end

end
