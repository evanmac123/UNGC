class OrganizationExcel
  include ActiveModel::Model
  require 'roo'

  attr_accessor :file

  def self.import(file)
      spreadsheet = Roo::Spreadsheet.open(file.path)
      header = spreadsheet.row(1)
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        organization = Organization.find_by(id: row["id"])
        organization.attributes = row.to_hash
        organization.save!
    end
  end
end
