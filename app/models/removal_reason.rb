# == Schema Information
#
# Table name: removal_reasons
#
#  id          :integer          not null, primary key
#  description :string(255)
#  old_id      :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class RemovalReason < ActiveRecord::Base
  validates_presence_of :description

  PUBLIC_REASONS = [
    :delisted,
    :requested
  ].freeze

  FILTERS = {
     :delisted         => 'Expelled due to failure to communicate progress',
     :not_applicable   => 'Other',
     :requested        => 'Participant requested withdrawal',
     :dialogue         => 'Expelled due to failure to engage in dialogue',
     :blacklisted      => 'Removed due to suspension or removal from the UN vendor list'

     # these reasons are also present in the database:
     # "Organization no longer exists",
     # "Other reason related to the Integrity Measures",
     # "Merger or acquisition",
     # "Transfer of commitment",
     # "Consolidation of commitment under the parent company",
     # "Non-responsive"
  }.freeze

  scope :publicly_delisted, -> {
    for_filter(PUBLIC_REASONS)
  }

  def self.for_filter(filters)
    descriptions = Array(filters).map { |f| FILTERS.fetch(f) }
    where(description: descriptions)
  rescue KeyError => e
    raise "Invalid RemovalReason #{e.message}. Expected one of: #{FILTERS.keys}"
  end

  def self.delisted
    find_by!(description: FILTERS[:delisted])
  end

  def self.blacklisted
    find_by!(description: FILTERS[:blacklisted])
  end

  def self.withdrew
    find_by!(description: FILTERS[:requested])
  end

  def public_reason?
    public_description.include?(self.description)
  end

  private

  def self.public_descriptions
    PUBLIC_REASONS.map do |sym|
      FILTERS.fetch(sym)
    end
  end

end
