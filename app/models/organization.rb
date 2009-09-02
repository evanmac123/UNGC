class Organization < ActiveRecord::Base
  validates_presence_of :name
  has_many :contacts
  belongs_to :sector
  belongs_to :organization_type
  belongs_to :country

  before_save :automatic_submit

  accepts_nested_attributes_for :contacts
  
  state_machine :state, :initial => :incomplete do
    event :submit do
      transition :from => :incomplete, :to => :pending
    end
    event :approve do
      transition :from => :pending, :to => :approved
    end
    event :reject do
      transition :from => :pending, :to => :rejected
    end
  end

  named_scope :incomplete, :conditions => {:state => "incomplete"}
  named_scope :pending, :conditions => {:state => "pending"}
  named_scope :approved, :conditions => {:state => "approved"}
  named_scope :rejected, :conditions => {:state => "rejected"}

  private
    def automatic_submit
      if state == "incomplete"
        # we want the organization to be in the submitted state when some
        # minimum amount of data is entered
        # TODO when do we move an organization to submitted state?
        self.submit if valid?
      end
    end
end
