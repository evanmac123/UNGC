class Organization < ActiveRecord::Base
  validates_presence_of :name
  has_many :contacts
  belongs_to :sector
  belongs_to :organization_type
  belongs_to :country

  accepts_nested_attributes_for :contacts
  
  state_machine :state, :initial => :incomplete do
    event :sign do
      transition :from => :incomplete, :to => :pending
    end
    event :approve do
      transition :from => :pending, :to => :approved
    end
    event :reject do
      transition :from => :pending, :to => :rejected
    end
  end
end
