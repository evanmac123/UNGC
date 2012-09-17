# == Schema Information
#
# Table name: removal_reasons
#
#  id          :integer(4)      not null, primary key
#  description :string(255)
#  old_id      :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

class RemovalReason < ActiveRecord::Base
  validates_presence_of :description

  FILTERS = {
     :delisted         => 'Failure to communicate progress',
     :not_applicable   => 'Not applicable',
     :requested        => 'Participant requested withdrawal',
     :dialogue         => 'Failure to engage in dialogue',
     :blacklisted      => 'Removed due to Blacklisting'
  }

  def self.for_filter(filter_types)
    if filter_types.is_a?(Array)
      filter_types.map! { |f| FILTERS[f] }
      where("description IN (?)", filter_types)
    else
      where("description = ?", FILTERS[filter_types])
    end
  end

  def self.delisted
    where(:description => FILTERS[:delisted]).first
  end

  def self.blacklisted
    where(:description => FILTERS[:blacklisted]).first
  end

  def self.withdrew
    where(:description => FILTERS[:requested]).first
  end

end
