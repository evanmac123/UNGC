class Redesign::Payload < ActiveRecord::Base
  def data
    if (json = read_attribute(:json_data))
      MultiJson.load(json, symbolize_keys: true)
    else
      {}
    end
  end

  def data=(hsh)
    json = if hsh
      MultiJson.dump(hsh)
    else
      '{}'
    end

    write_attribute :json_data, json
  end

  def tags
    data.fetch(:taggings, {})
  end

  def content_type
    data.fetch(:meta_tags, {}).fetch(:content_type, nil)
  end

  def copy
    Redesign::Payload.create!(
      container_id: container_id,
      json_data:    json_data
    )
  end
end
