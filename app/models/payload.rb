# == Schema Information
#
# Table name: payloads
#
#  id             :integer          not null, primary key
#  container_id   :integer          not null
#  json_data      :text(4294967295) not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  created_by_id  :integer
#  updated_by_id  :integer
#  approved_by_id :integer
#  approved_at    :datetime
#

class Payload < ActiveRecord::Base
  include TrackCurrentUser
  belongs_to :approved_by, :class_name => 'Contact', :foreign_key => :approved_by_id
  belongs_to :container

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
    Payload.create!(
      container_id: container_id,
      json_data:    json_data
    )
  end

  def approve!(contact)
    @current_contact = contact
    self.approved_by_id = contact.id
    self.approved_at = Time.current
    self.save!
  end
end
