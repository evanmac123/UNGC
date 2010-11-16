# == Schema Information
#
# Table name: roles
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  old_id        :integer(4)
#  created_at    :datetime
#  updated_at    :datetime
#  initiative_id :integer(4)
#

class Role < ActiveRecord::Base
  validates_presence_of :name, :description
  has_and_belongs_to_many :contacts, :join_table => "contacts_roles"
  belongs_to :initiative
  default_scope :order => :name
  
  FILTERS = {
    :ceo                      => 3,
    :contact_point            => 4,
    :general_contact          => 9,
    :financial_contact        => 2,
    :network_focal_point      => 5,
    :network_representative   => 12,
    :network_report_recipient => 13
  }
  
  named_scope :visible_to, lambda { |user|
    if user.user_type == Contact::TYPE_ORGANIZATION
      roles_ids = [Role.ceo, Role.contact_point, Role.general_contact, Role.financial_contact].collect(&:id)
      # financial contact for business only
      roles_ids << Role.all(:conditions => ["initiative_id in (?)", user.organization.initiative_ids]).collect(&:id)
      { :conditions => ['id in (?)', roles_ids.flatten] }
    elsif user.user_type == Contact::TYPE_NETWORK
      roles_ids = [Role.network_focal_point, Role.network_representative, Role.network_report_recipient].collect(&:id)
      { :conditions => ['id in (?)', roles_ids.flatten] }
    else
      {}
    end
  }

  def self.network_contacts
    find :all, :conditions => ["old_id in (?)", [5,12,13]]
  end
  
  def self.network_focal_point
    find :first, :conditions => ["old_id=?", FILTERS[:network_focal_point]]
  end
  
  def self.network_representative
    find :first, :conditions => ["old_id=?", FILTERS[:network_representative]]
  end

  def self.network_report_recipient
    find :first, :conditions => ["old_id=?", FILTERS[:network_report_recipient]]
  end  
  
  def self.ceo
    find :first, :conditions => ["old_id=?", FILTERS[:ceo]]
  end
  
  def self.contact_point
    find :first, :conditions => ["old_id=?", FILTERS[:contact_point]]
  end
  
  def self.general_contact
    find :first, :conditions => ["old_id=?", FILTERS[:general_contact]]
  end
  
  def self.financial_contact
    find :first, :conditions => ["old_id=?", FILTERS[:financial_contact]]
  end
  
  def self.login_roles
    [Role.contact_point, Role.network_report_recipient]
  end
end
