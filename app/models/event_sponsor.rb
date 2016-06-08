# == Schema Information
#
# Table name: event_sponsors
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  sponsor_id :integer
#

class EventSponsor < ActiveRecord::Base
  belongs_to :event
  belongs_to :sponsor
end
