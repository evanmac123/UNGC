class Redesign::Container < ActiveRecord::Base
  belongs_to :public_payload, class_name: 'Redesign::Payload'
  belongs_to :draft_payload, class_name: 'Redesign::Payload'
end
